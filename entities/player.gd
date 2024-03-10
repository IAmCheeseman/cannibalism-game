extends CharacterBody2D
class_name Player

@onready var sprite: Sprite2D = $Sprite
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sword: Sword = $Sword

@export var speed: float = 150
@export var accel: float = 15

static var instance: Player

func _init() -> void:
  instance = self

func _process(delta: float) -> void:
  var input := Input.get_vector("left", "right", "up", "down")
  input = input.normalized()

  if input.length() > 0:
    anim.play("walk")
  else:
    anim.play("idle")

  var mouse_pos = get_local_mouse_position()
  sprite.flip_h = mouse_pos.x > 0
  
  velocity = Utils.delta_lerp(velocity, input * speed, accel, delta)

  move_and_slide()

  sword.target = get_global_mouse_position()
  if Input.is_action_just_pressed("attack"):
    sword.attack()
