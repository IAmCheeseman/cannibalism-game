extends Enemy
class_name Archer

@onready var charge_up_timer: Timer = $ChargeUp
@onready var flee_timer: Timer = $FleeTimer
@onready var sprite: Sprite2D = $Sprite
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var soft_collision: SoftCollision = $SoftCollision
@onready var gun_sprite: Sprite2D = $GunSprite

@export var speed := 80.0
@export var accel := 15.0
@export var attack_distance := 16.0 * 5.0

const BULLET := preload("res://scenes/enemy/bullet.tscn")

var s_pursue := State.new("pursue", null, _pursue_process, null)
var s_attack := State.new("attack", _attack_enter, _attack_process, _attack_exit)
var s_flee := State.new("flee", _flee_enter, _flee_process, null)
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

  gun_sprite.look_at(target)

func _attack_enter() -> void:
  charge_up_timer.start()

func _attack_process(delta: float) -> void:
  target = global_position
  _move_to_target(delta)

  if not charge_up_timer.is_stopped():
    var percentage = 1 - charge_up_timer.time_left / charge_up_timer.wait_time
    sprite.material.set_shader_parameter("strength", percentage)

  gun_sprite.look_at(Player.instance.global_position)

  animation.play("idle")

func _attack_exit() -> void:
  sprite.material.set_shader_parameter("strength", 0)

  var bullet_count := 8
  var spread := deg_to_rad(2)
  var spread_start := -spread * (bullet_count / 2.)
  var shoot_target := Player.instance.global_position
  for i in 8:
    var angle = spread_start + (i * spread)
    var direction = global_position.direction_to(shoot_target).rotated(angle)
    var bullet = BULLET.instantiate()
    bullet.velocity = direction * randf_range(150, 175)
    bullet.global_position = global_position
    add_sibling(bullet)

  velocity = -global_position.direction_to(shoot_target) * 100

func _flee_enter() -> void:
  flee_timer.start()

func _flee_process(delta: float) -> void:
  var direction = -global_position.direction_to(Player.instance.global_position)
  velocity = Utils.delta_lerp(velocity, direction * speed, accel, delta)
  velocity += soft_collision.get_push_vector() * delta
  move_and_slide()

func _on_died() -> void:
  queue_free()

func _on_charge_up_timeout() -> void:
  state_machine.set_current(s_flee)

func _on_flee_timeout() -> void:
  state_machine.set_current(s_pursue)