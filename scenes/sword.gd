extends Node2D
class_name Sword

@onready var cooldown: Timer = $Cooldown
@onready var sprite: Sprite2D = $Sprite

@export var swing_scene: PackedScene

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

  var swing = swing_scene.instantiate()
  swing.global_position = global_position
  swing.rotation = rotation
  $"/root/World".add_child(swing)
