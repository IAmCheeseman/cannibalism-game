extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite

var texture: Texture2D
var direction: Vector2
var speed: float

func _ready() -> void:
  sprite.texture = texture
  sprite.offset.y = -texture.get_height() * 0.5
  apply_central_impulse(direction * speed)
