extends Node2D
class_name SpriteShadow

@export var shadow_sprite: Sprite2D

var shadow: Sprite2D

func _ready() -> void:
  shadow = Sprite2D.new()
  shadow.offset = shadow_sprite.offset
  shadow.texture = shadow_sprite.texture
  shadow.vframes = shadow_sprite.vframes
  shadow.hframes = shadow_sprite.hframes
  ShadowGroup.instance.add_child(shadow)

func _process(_delta: float) -> void:
  shadow.global_position = shadow_sprite.global_position
  shadow.scale = shadow_sprite.scale * Vector2(1, -0.5)
  shadow.skew = -shadow_sprite.skew
  shadow.flip_h = shadow_sprite.flip_h
  shadow.flip_v = shadow_sprite.flip_v
  shadow.frame = shadow_sprite.frame

func _exit_tree() -> void:
  shadow.queue_free()
