extends Node
class_name WorldGenerator

@export var tile_map: TileMap
@export var player: Player
@export var area: Area

const NOISE_RANGE = 0.57

const PORTAL = preload("res://scenes/portal.tscn")

func add_tiles(list: Dictionary, pos: Vector2i) -> void:
  list[pos] = true
  list[pos + Vector2i(-1, 0)] = true
  list[pos + Vector2i(-1, -1)] = true
  list[pos + Vector2i(0, -1)] = true

func add_rect(list: Dictionary, rect: Rect2i) -> void:
  for x in rect.size.x:
    for y in rect.size.y:
      list[Vector2i(rect.position.x + x, rect.position.y + y)] = true
  print(rect.size)

func normalized_noise(noise: FastNoiseLite, x: float, y: float) -> float:
  return (noise.get_noise_2d(x, y) + NOISE_RANGE) / (NOISE_RANGE * 2)

func can_spawn_enemy_at(x: int, y: int) -> bool:
  return tile_map.get_cell_source_id(0, Vector2i(x,     y))     != -1 \
    and  tile_map.get_cell_source_id(0, Vector2i(x + 1, y))     != -1 \
    and  tile_map.get_cell_source_id(0, Vector2i(x,     y + 1)) != -1 \
    and  tile_map.get_cell_source_id(0, Vector2i(x - x, y))     != -1 \
    and  tile_map.get_cell_source_id(0, Vector2i(x,     y - 1)) != -1

func generate() -> void:
  randomize()

  area.island_noise.seed = randi()
  area.alt_noise.seed = randi()

  var sand_tiles := {}
  var inner_tiles := {} 
  var alt_inner_tiles := {}

  var tile_size: Vector2 = tile_map.tile_set.tile_size

  for x in area.island_size.x:
    for y in area.island_size.y:
      var n = normalized_noise(area.island_noise, x, y)
      var p = Vector2(x / float(area.island_size.x), y / float(area.island_size.y))
      n *= sin(PI * p.x) * sin(PI * p.y)

      if n > 0.2:
        add_tiles(sand_tiles, Vector2i(x, y))
      if n > 0.3:
        var alt_n = normalized_noise(area.alt_noise, x, y)
        if alt_n > 0.4:
          add_tiles(inner_tiles, Vector2i(x, y))
        else:
          add_tiles(alt_inner_tiles, Vector2i(x, y))

  var portal = PORTAL.instantiate()
  var cell = sand_tiles.keys().pick_random()
  add_rect(sand_tiles, Rect2i(cell - Vector2i.ONE * 2, Vector2i.ONE * 5))
  portal.position = Vector2(cell) * tile_size
  add_child(portal)

  LevelManager.level += 1

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

  for i in LevelManager.level * 3:
    var enemy = area.enemy_pool.pick_random().instantiate()
    var tile = sand_tiles.keys().pick_random()
    enemy.position = Vector2(tile) * tile_size + tile_size / 2
    add_sibling(enemy)

  player.position = tile_map.get_used_rect().get_center() * Vector2i(tile_size)
