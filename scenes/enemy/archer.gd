extends Enemy
class_name Archer

@onready var charge_up_timer: Timer = $ChargeUp
@onready var sprite: Sprite2D = $Sprite
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var soft_collision: SoftCollision = $SoftCollision

@export var speed := 80.0
@export var accel := 15.0
@export var attack_distance := 16.0 * 5.0

var s_pursue := State.new("pursue", null, _pursue_process, null)
var s_attack := State.new("attack", _attack_enter, _attack_process, _attack_exit)
var state_machine := StateMachine.new()

var target: Vector2

func _ready() -> void:
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
  sprite.scale.x = 1 if velocity.x < 0 else -1

func _attack_enter() -> void:
  charge_up_timer.start()

func _attack_process(delta: float) -> void:
  target = global_position
  _move_to_target(delta)

  if not charge_up_timer.is_stopped():
    var percentage = 1 - charge_up_timer.time_left / charge_up_timer.wait_time
    sprite.material.set_shader_parameter("strength", percentage)

  animation.play("walk")

func _attack_exit() -> void:
  sprite.material.set_shader_parameter("strength", 0)

func _on_died() -> void:
  queue_free()

func _on_charge_up_timeout() -> void:
  state_machine.set_current(s_pursue)

