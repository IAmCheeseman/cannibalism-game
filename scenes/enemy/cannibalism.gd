extends Area2D

@onready var eat_indicator := $EatIndicator

@export var entity: Enemy

func _ready() -> void:
  eat_indicator.hide()

func _process(delta: float) -> void:
  for area in get_overlapping_areas():
    if Player.instance.can_eat():
      eat_indicator.show()
      Player.instance.eat_target = entity

func _on_area_exited(_area:Area2D) -> void:
  eat_indicator.hide()
  Player.instance.eat_target = null

