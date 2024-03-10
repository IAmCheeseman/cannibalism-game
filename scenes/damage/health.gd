extends Node
class_name Health

@export var max_health := 15.0
@export var defense := 0.0
@export var hurtbox: Hurtbox
@export var entity: CharacterBody2D

@onready var health := max_health

signal died
signal took_damage

func _ready() -> void:
  hurtbox.took_damage.connect(take_damage)

func take_damage(attack: Attack) -> void:
  var total_defense := 0.
  if defense != 0:
    total_defense = defense / 2
  health -= attack.damage - total_defense

  entity.velocity = attack.knockbackDirection

  took_damage.emit()

  if health <= 0:
    died.emit()
    entity.queue_free()
