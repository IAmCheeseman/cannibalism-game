extends CharacterBody2D
class_name Player

@onready var sprite: Sprite2D = $Sprite
@onready var shadow: SpriteShadow = $Shadow
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sword: Sword = $Sword
@onready var health: Health = $Health

@export var speed: float = 150
@export var accel: float = 15

const BLOOD_SPLATTER := preload("res://scenes/effects/blood.tscn")
const CORPSE_SPRITE := preload("res://assets/sam_corpse.png")
const CORPSE := preload("res://scenes/corpse.tscn")

static var instance: Player

var eat_target: Enemy

var max_stamina := 100.0
var stamina := max_stamina

var s_default := State.new("default", null, _default_process, null)
var s_eating := State.new("eat", null, _eat_process, _eat_exit)
var s_dead := State.new("dead", null, null, null)
var state_machine := StateMachine.new()

var eat_speed_modifier := 1.0

func _init() -> void:
  instance = self

func _ready() -> void:
  state_machine.set_current(s_default)

func _process(delta: float) -> void:
  state_machine.process(delta)

func _default_process(delta: float) -> void:
  if health.is_dead:
    return

  var input := Input.get_vector("left", "right", "up", "down")
  input = input.normalized()

  if input.length() > 0:
    anim.play("walk")
    take_stamina(5 * delta * eat_speed_modifier)
  else:
    anim.play("idle")

  var mouse_pos = get_local_mouse_position()
  sprite.flip_h = mouse_pos.x > 0
  
  velocity = Utils.delta_lerp(velocity, input * speed * eat_speed_modifier, accel, delta)
  eat_speed_modifier = min(eat_speed_modifier + delta * 0.5, 1)

  move_and_slide()

  sword.target = get_global_mouse_position()
  if Input.is_action_just_pressed("attack"):
    take_stamina(sword.stamina_cost)
    sword.attack()

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("eat") and eat_target:
    if not is_instance_valid(eat_target):
      eat_target = null
      return
    state_machine.set_current(s_eating)

func _eat_process(_delta: float) -> void:
  var direction = global_position.direction_to(eat_target.global_position)
  velocity = direction * 400

  if global_position.distance_to(eat_target.global_position) < 5:
    state_machine.set_current(s_default)

  move_and_slide()

func _eat_exit() -> void:
  var blood = BLOOD_SPLATTER.instantiate()
  blood.position = eat_target.position
  add_sibling(blood)

  stamina = min(stamina + max_stamina / 4, max_stamina)

  eat_target.health.kill()
  eat_target.queue_free()
  eat_speed_modifier = 0
  eat_target = null

func _on_died() -> void:
  state_machine.set_current(s_dead)
  sprite.hide()

  var corpse := CORPSE.instantiate()
  corpse.global_position = global_position
  corpse.direction = velocity.normalized()
  corpse.speed = velocity.length()
  corpse.texture = CORPSE_SPRITE
  call_deferred("add_sibling", corpse)

  shadow.queue_free()
  sword.queue_free()

func take_stamina(amount: float) -> void:
  stamina -= amount
  if stamina <= 0:
    health.kill()

func can_eat() -> bool:
  return eat_target == null or not eat_target.is_inside_tree()
