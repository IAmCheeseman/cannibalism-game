extends Node2D

func _ready() -> void:
  var world_generator := $WorldGenerator
  world_generator.generate()
