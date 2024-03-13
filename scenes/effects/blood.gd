extends Node2D

func _ready() -> void:
  const BLOOD_SPLATTER = preload("res://scenes/effects/blood_splatter.tscn")
  for i in 8:
    var angle = randf() * TAU
    var offset = randf() * 32
    var vector_offset = Vector2(cos(angle), sin(angle)) * offset
    var splat = BLOOD_SPLATTER.instantiate()
    splat.global_position = global_position + vector_offset
    splat.rotation = angle + PI
    add_sibling(splat)

