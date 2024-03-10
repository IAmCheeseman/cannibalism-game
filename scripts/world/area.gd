extends Resource
class_name Area

@export_category("Island Shape")
@export var island_size := Vector2i(24, 24)
@export var island_noise: FastNoiseLite
@export var alt_noise: FastNoiseLite
@export_range(0, 1) var sand_threshold := 0.2
@export_range(0, 1) var inner_threshold := 0.3
@export_range(0, 1) var alt_inner_threshold := 0.33
@export var props: Array[Prop]

@export_category("Tiles")
@export var sand_layer := 0
@export var inner_layer := 1
@export var alt_inner_layer := 2

@export var sand_terrain := 0
@export var inner_terrain := 1
@export var alt_inner_terrain := 2
