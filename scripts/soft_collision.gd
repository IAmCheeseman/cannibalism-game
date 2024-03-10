extends Area2D
class_name SoftCollision

@export var push_strength := 5.0

func get_push_vector() -> Vector2:
  var vector = Vector2.ZERO
  for soft_collision in get_overlapping_areas():
    vector += global_position.direction_to(soft_collision.global_position)
  return -vector.normalized() * push_strength
