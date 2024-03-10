extends Area2D
class_name Hurtbox

@onready var invincibility_timer: Timer

@export var iframes = 0.1

signal took_damage(attack: Attack)

func _ready() -> void:
  invincibility_timer = Timer.new()
  invincibility_timer.one_shot = true
  add_child(invincibility_timer)

func take_damage(attack: Attack) -> bool:
  if not invincibility_timer.is_stopped():
    return false

  took_damage.emit(attack)
  invincibility_timer.start(iframes)
  return true
