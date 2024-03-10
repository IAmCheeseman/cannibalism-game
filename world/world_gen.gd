extends Node
class_name WorldGenerator

@export var island_size: Vector2i = Vector2i(32, 32)
@export var tile_map: TileMap
@export var player: Player
@export var island_noise: FastNoiseLite
@export var alt_noise: FastNoiseLite

const TREE = preload("res://entities/props/tree.tscn")

const NOISE_RANGE = 0.57

func add_tiles(list: Array[Vector2i], pos: Vector2i) -> void:
  list.append(pos)
  list.append(pos + Vector2i(-1, 0))
  list.append(pos + Vector2i(-1, -1))
  list.append(pos + Vector2i(0, -1))

func normalized_noise(noise: FastNoiseLite, x: float, y: float) -> float:
  return (noise.get_noise_2d(x, y) + NOISE_RANGE) / (NOISE_RANGE * 2)


func generate() -> void:
  randomize()

  island_noise.seed = randi()
  alt_noise.seed = randi()

  var sand_tiles: Array[Vector2i] = []
  var grass_tiles: Array[Vector2i] = []
  var alt_tiles: Array[Vector2i] = []

  var tile_size: Vector2 = tile_map.tile_set.tile_size

  for x in island_size.x:
    for y in island_size.y:
      var n = normalized_noise(island_noise, x, y)
      var p = Vector2(x / float(island_size.x), y / float(island_size.y))
      n *= sin(PI * p.x) * sin(PI * p.y)

      if n > 0.2:
        add_tiles(sand_tiles, Vector2i(x, y))
      if n > 0.3:
        var alt_n = normalized_noise(alt_noise, x, y)
        if alt_n > 0.4:
          add_tiles(grass_tiles, Vector2i(x, y))
        else:
          if randf() < 0.33:
            var tree = TREE.instantiate()
            var pos = Vector2(x, y) * Vector2(tile_size)
            pos += tile_size * Vector2(randf(), randf())
            tree.position = floor(pos)
            add_sibling(tree)
            
            add_tiles(alt_tiles, Vector2i(x, y))

  tile_map.set_cells_terrain_connect(0, sand_tiles, 0, 1)
  tile_map.set_cells_terrain_connect(1, grass_tiles, 0, 0)
  tile_map.set_cells_terrain_connect(2, alt_tiles, 0, 2)

  player.position = tile_map.get_used_rect().get_center() * Vector2i(tile_size)
