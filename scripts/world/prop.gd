extends Resource
class_name Prop

enum TileTypes {
  SAND,
  INNER,
  ALT_INNER,
}

@export var scene: PackedScene
@export var chance := 0.333
@export var grid_aligned := false
@export var tiles: Array[TileTypes]
