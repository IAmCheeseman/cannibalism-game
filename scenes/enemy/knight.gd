extends Enemy
class_name Knight

@onready var sprite: Sprite2D = $Sprite
@onready var animation: AnimationPlayer = $Sprite/AnimationPlayer
@onready var soft_collision: SoftCollision = $SoftCollision
@onready var sword: Sword = $Sword
@onready var attack_timer: Timer = $Attack
@onready var attack_charge: Timer = $AttackCharge
@onready var flee_check_rc: RayCast2D = $FleeCheck

@export var speed := 80.0
@export var accel := 15.0
@export var flee_distance: float = 5 * 16
@export var attack_distance := 24.0

const CORPSE_SPRITE := preload("res://assets/knight_corpse.png")
const CORPSE := preload("res://scenes/corpse.tscn")

var s_pursue := State.new("pursue", null, _pursue_process, null)
var s_attack := State.new("attack", _attack_enter, _attack_process, null)
var s_flee := State.new("flee", _flee_enter, _flee_process, null)
var state_machine := StateMachine.new()
var target: Vector2

func _ready() -> void:
  sprite.material = sprite.material.duplicate()
  state_machine.set_current(s_pursue)

func _process(delta: float) -> void:
  state_machine.process(delta)

func _move_to_target(delta: float) -> void:
  var direction = position.direction_to(target)
  velocity = Utils.delta_lerp(velocity, direction * speed, accel, delta)
  velocity += soft_collision.get_push_vector() * delta
  move_and_slide()

func _pursue_process(delta: float) -> void:
  if not Player.instance:
    return 

  target = Player.instance.position
  _move_to_target(delta)

  var distance = position.distance_to(target)
  if distance < attack_distance:
    state_machine.set_current(s_attack)

  animation.play("walk")
  sprite.flip_h = velocity.x > 0

  sword.target = Player.instance.global_position

func _attack_enter() -> void:
  attack_charge.start()
  attack_timer.start()

func _attack_process(delta: float) -> void:
  target = global_position
  _move_to_target(delta)

  if not attack_charge.is_stopped():
    var percentage = 1 - attack_charge.time_left / attack_charge.wait_time
    sprite.material.set_shader_parameter("strength", percentage)

  animation.play("idle")

func _on_attack_charge_timeout() -> void:
  sprite.material.set_shader_parameter("strength", 0)
  sword.attack()

func _on_attack_timeout() -> void:
  state_machine.set_current(s_flee)

func _flee_enter() -> void:
  target = target - position.direction_to(target) * flee_distance

func _flee_process(delta: float) -> void:
  _move_to_target(delta)

  flee_check_rc.target_position = velocity.normalized() * 16

  var distance = position.distance_to(target)
  if distance < 5 or flee_check_rc.is_colliding():
    state_machine.set_current(s_pursue)

  animation.play("walk")
  sprite.flip_h = velocity.x > 0

  sword.target = global_position + velocity
  queue_redraw()

func _on_died() -> void:
  var corpse := CORPSE.instantiate()
  corpse.global_position = global_position
  corpse.direction = velocity.normalized()
  corpse.speed = velocity.length()
  corpse.texture = CORPSE_SPRITE
  call_deferred("add_sibling", corpse)
  queue_free()

