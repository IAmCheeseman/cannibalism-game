extends Node
class_name Health

@export var max_health := 15.0
@export var defense := 0.0
@export var hurtbox: Hurtbox
@export var entity: CharacterBody2D

@onready var health := max_health

signal died
signal took_damage

var is_dead := false

func _ready() -> void:
  hurtbox.took_damage.connect(take_damage)

func kill() -> void:
  is_dead = true
  died.emit()

func take_damage(attack: Attack) -> void:
  if is_dead:
    return

  var total_defense := 0.
  if defense != 0:
    total_defense = defense / 2
  health -= attack.damage - total_defense

  entity.velocity = attack.knockbackDirection

  took_damage.emit()

  if health <= 0:
    kill()
