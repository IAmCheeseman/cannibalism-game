extends CharacterBody2D

const CORPSE_SPRITE := preload("res://assets/knight_corpse.png")
const CORPSE := preload("res://scenes/corpse.tscn")

@onready var sprite: Sprite2D = $Sprite
@onready var animation: AnimationPlayer = $Sprite/AnimationPlayer
@onready var soft_collision: SoftCollision = $SoftCollision
@onready var flee_check_rc: RayCast2D = $FleeCheck

@export var run_speed := 160.0
@export var normal_speed := 80.0
@export var accel := 15.0
@export var flee_distance: float = 5 * 16
@export var attack_distance := 24.0

var s_pursue := State.new("pursue", null, _pursue_process, null)
var s_attack := State.new("attack", _attack_enter, _attack_process, _attack_exit)
var s_flee := State.new("flee", _flee_enter, _flee_process, null)
var state_machine := StateMachine.new()
var target: Vector2

func _ready() -> void:
  sprite.material = sprite.material.duplicate()
  state_machine.set_current(s_pursue)

func _process(delta: float) -> void:
  state_machine.process(delta)

func _move_to_target(speed: float, delta: float) -> void:
  var direction = position.direction_to(target)
  velocity = Utils.delta_lerp(velocity, direction * speed, accel, delta)
  velocity += soft_collision.get_push_vector() * delta
  move_and_slide()

func _pursue_process(delta: float) -> void:
  if not Player.instance:
    return 

  target = Player.instance.position
  _move_to_target(normal_speed, delta)

  var distance = position.distance_to(target)
  var mouse_pos = get_global_mouse_position()
  var target_direction = position.direction_to(target)
  var mouse_direction = target.direction_to(mouse_pos)

  var speed = normal_speed
  if target_direction.dot(mouse_direction) < 0:
    target = target - target_direction * flee_distance
    speed = run_speed

  var direction = position.direction_to(target)
  velocity = Utils.delta_lerp(velocity, direction * speed, accel, delta)
  velocity += soft_collision.get_push_vector() * delta
  move_and_slide()

  if distance < attack_distance:
    state_machine.set_current(s_attack)

  animation.play("walk")
  sprite.scale.x = -1 if velocity.x > 0 else 1

func _attack_enter() -> void:
  animation.play("attack")

func _attack_process(delta: float) -> void:
  target = global_position
  _move_to_target(0, delta)

  var percentage = animation.current_animation_position / animation.current_animation_length
  sprite.material.set_shader_parameter("strength", percentage)

  animation.play("attack")

func _attack_exit() -> void:
  sprite.material.set_shader_parameter("strength", 0)

func _on_attack_charge_timeout() -> void:
  sprite.material.set_shader_parameter("strength", 0)

func _flee_enter() -> void:
  target = target - position.direction_to(target) * flee_distance

func _flee_process(delta: float) -> void:
  _move_to_target(normal_speed, delta)

  flee_check_rc.target_position = velocity.normalized() * 16

  var distance = position.distance_to(target)
  if distance < 5 or flee_check_rc.is_colliding():
    state_machine.set_current(s_pursue)

  animation.play("walk")
  sprite.scale.x = -1 if velocity.x > 0 else 1

func _on_died() -> void:
  var corpse := CORPSE.instantiate()
  corpse.global_position = global_position
  corpse.direction = velocity.normalized()
  corpse.speed = velocity.length()
  corpse.texture = CORPSE_SPRITE
  call_deferred("add_sibling", corpse)
  queue_free()

func _on_animation_finished(anim_name: StringName) -> void:
  if anim_name == "attack":
    state_machine.set_current(s_pursue)
