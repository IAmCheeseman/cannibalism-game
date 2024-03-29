extends Node
class_name WorldGenerator

@export var tile_map: TileMap
@export var player: Player
@export var area: Area

const NOISE_RANGE = 0.57
const PORTAL = preload("res://scenes/portal.tscn")

signal enemy_spawned(enemy)

func add_tiles(list: Dictionary, pos: Vector2i) -> void:
  list[pos] = true
  list[pos + Vector2i(-1, 0)] = true
  list[pos + Vector2i(-1, -1)] = true
  list[pos + Vector2i(0, -1)] = true

func add_rect(list: Dictionary, rect: Rect2i) -> void:
  for x in rect.size.x:
    for y in rect.size.y:
      list[Vector2i(rect.position.x + x, rect.position.y + y)] = true

func normalized_noise(noise: FastNoiseLite, x: float, y: float) -> float:
  return (noise.get_noise_2d(x, y) + NOISE_RANGE) / (NOISE_RANGE * 2)

func flood_fill(tiles: Dictionary, cell: Vector2i, level: int = 1) -> void:
  if level > 5 or tiles.has(cell):
    return

  tiles[cell] = true

  flood_fill(tiles, cell + Vector2i.RIGHT, level + 1)
  flood_fill(tiles, cell + Vector2i.LEFT, level + 1)
  flood_fill(tiles, cell + Vector2i.UP, level + 1)
  flood_fill(tiles, cell + Vector2i.DOWN, level + 1)

func generate() -> void:
  randomize()

  area.island_noise.seed = randi()
  area.alt_noise.seed = randi()

  var sand_tiles := {}
  var inner_tiles := {} 
  var alt_inner_tiles := {}
  var enemy_spawns: Array[Vector2] = []

  var tile_size: Vector2 = tile_map.tile_set.tile_size

  for x in area.island_size.x:
    for y in area.island_size.y:
      var n = normalized_noise(area.island_noise, x, y)
      var p = Vector2(x / float(area.island_size.x), y / float(area.island_size.y))
      n *= sin(PI * p.x) * sin(PI * p.y) * 2

      if n > 0.4:
        add_tiles(sand_tiles, Vector2i(x, y))
      if n > 0.5:
        enemy_spawns.append(Vector2(x, y))
      if n > 0.6:
        var alt_n = normalized_noise(area.alt_noise, x, y)
        if alt_n > 0.4:
          add_tiles(inner_tiles, Vector2i(x, y))
        else:
          add_tiles(alt_inner_tiles, Vector2i(x, y))

  var portal = PORTAL.instantiate()
  portal.world_generator = self
  var cell = sand_tiles.keys().pick_random()
  add_rect(sand_tiles, Rect2i(cell - Vector2i.ONE * 2, Vector2i.ONE * 5))
  portal.position = Vector2(cell) * tile_size
  add_child(portal)

  var player_position = floor(area.island_size / 2)
  flood_fill(sand_tiles, player_position)
  flood_fill(sand_tiles, player_position + Vector2i.RIGHT)
  flood_fill(sand_tiles, player_position + Vector2i.DOWN)
  flood_fill(sand_tiles, player_position + Vector2i.LEFT)
  flood_fill(sand_tiles, player_position + Vector2i.UP)
  flood_fill(sand_tiles, player_position + Vector2i.UP + Vector2i.LEFT)
  flood_fill(sand_tiles, player_position + Vector2i.UP + Vector2i.RIGHT)
  flood_fill(sand_tiles, player_position + Vector2i.RIGHT + Vector2i.DOWN)
  flood_fill(sand_tiles, player_position + Vector2i.LEFT + Vector2i.DOWN)

  tile_map.set_cells_terrain_connect(
    area.sand_layer, sand_tiles.keys(), 0, area.sand_terrain)
  tile_map.set_cells_terrain_connect(
    area.inner_layer, inner_tiles.keys(), 0, area.inner_terrain)
  tile_map.set_cells_terrain_connect(
    area.alt_inner_layer, alt_inner_tiles.keys(), 0, area.alt_inner_terrain)

  for prop in area.props:
    var possible_tiles = []
    for tile in prop.tiles:
      match tile:
        Prop.TileTypes.SAND: possible_tiles += sand_tiles.keys()
        Prop.TileTypes.INNER: possible_tiles += inner_tiles.keys()
        Prop.TileTypes.ALT_INNER: possible_tiles += alt_inner_tiles.keys()
    
    var count = floor(possible_tiles.size() * prop.chance)
    possible_tiles.shuffle()
    for i in count:
      var instance = prop.scene.instantiate()
      instance.position = Vector2(possible_tiles.pop_back()) * tile_size
      if not prop.grid_aligned:
        instance.position += Vector2(tile_size.x * randf(), tile_size.y * randf())
      if instance.global_position.distance_to(portal.global_position) < 32:
        instance.queue_free()
        continue
      add_sibling(instance)

  for i in 2 + LevelManager.level:
    var enemy = area.enemy_pool.pick_random().instantiate()
    var tile = enemy_spawns.pick_random()
    enemy.position = Vector2(tile) * tile_size + tile_size / 2
    enemy_spawned.emit(enemy)
    add_sibling(enemy)

  player.position = Vector2(player_position) * tile_size

  LevelManager.level += 1
