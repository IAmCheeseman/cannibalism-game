extends Node2D

@onready var hitbox := $Hitbox

func _ready() -> void:
  hitbox.attack.knockbackDirection = Vector2.from_angle(rotation) * 250

