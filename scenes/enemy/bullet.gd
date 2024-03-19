extends Node2D

var velocity: Vector2

func _process(delta: float) -> void:
  position += velocity * delta
  look_at(position + velocity)

func _on_body_entered(_body: Node2D) -> void:
  queue_free()

func _on_hitbox_hit(_attack: Attack, _hurtbox: Hurtbox) -> void:
  queue_free()

