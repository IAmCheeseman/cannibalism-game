extends Node
class_name Health

const BLOOD_SPLATTER = preload("res://scenes/effects/blood_splatter.tscn")

@export var max_health := 15.0
@export var defense := 0.0
@export var hurtbox: Hurtbox
@export var entity: CharacterBody2D
@export var invincible := false

@onready var health := max_health

signal died
signal took_damage

var is_dead := false

func _ready() -> void:
  hurtbox.took_damage.connect(take_damage)

func is_below_percentage(percentage: float) -> bool:
  return health / max_health < percentage

func kill() -> void:
  is_dead = true
  died.emit()

func take_damage(attack: Attack) -> void:
  if is_dead or invincible:
    return

  var total_defense := 0.
  if defense != 0:
    total_defense = defense / 2
  health -= attack.damage - total_defense

  entity.velocity = attack.knockbackDirection

  for i in randi_range(1, 3):
    var angle = attack.knockbackDirection.angle() + randf_range(-PI / 4, PI / 4)
    var offset = randf() * 32
    var vector_offset = Vector2(cos(angle), sin(angle)) * offset
    var splat = BLOOD_SPLATTER.instantiate()
    splat.global_position = entity.global_position + vector_offset
    splat.rotation = angle + PI
    entity.add_sibling(splat)

  took_damage.emit()

  if health <= 0:
    kill()
