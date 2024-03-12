extends Area2D

@onready var eat_indicator := $EatIndicator

@export var entity: Enemy

func _ready() -> void:
  eat_indicator.hide()

func _process(delta: float) -> void:
  var areas = get_overlapping_areas()
  if areas.size() == 0:
    eat_indicator.hide()
    if Player.instance.eat_target == entity:
      Player.instance.eat_target = null
  for area in areas:
    if Player.instance.can_eat():
      eat_indicator.show()
      Player.instance.eat_target = entity

