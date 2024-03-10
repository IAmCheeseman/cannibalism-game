extends Node2D
class_name Sword

@onready var cooldown: Timer = $Cooldown
@onready var sprite: Sprite2D = $Sprite
@onready var swing_sprite: AnimatedSprite2D = $Swing

var swing_dir := 1.
var hold_angle: float
var target: Vector2

func _ready() -> void:
  hold_angle = sprite.rotation

func _process(delta: float) -> void:
  look_at(target)

  sprite.scale.y = swing_dir
  sprite.rotation = lerp_angle(
    sprite.rotation,
    (hold_angle * swing_dir),
    16 * delta)

func attack() -> void:
  if not cooldown.is_stopped():
    return

  cooldown.start()
  swing_dir = -swing_dir
  swing_sprite.show()
  swing_sprite.play("swing")


func _on_swing_animation_looped() -> void:
  swing_sprite.stop()
  swing_sprite.hide()

