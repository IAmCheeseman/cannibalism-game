extends Area2D

@onready var eat_indicator := $EatIndicator

@export var entity: Enemy

func _ready() -> void:
  add_to_group("cannibalism")
  eat_indicator.hide()

func _process(delta: float) -> void:
  var areas = get_overlapping_areas()
  var player = Player.instance
  if areas.size() == 0:
    eat_indicator.hide()
    if player.eat_target == entity:
      player.eat_target = null
  for area in areas:
    var this_dist = player.global_position.distance_to(entity.global_position)
    var closer = false
    if player.eat_target != null:
      closer = player.global_position.distance_to(player.eat_target.global_position) < this_dist
    if player.can_override_eat_target() and closer or player.eat_target == null:
      get_tree().call_group("cannibalism", "priority_taken")
      eat_indicator.show()
      Player.instance.eat_target = entity

func priority_taken() -> void:
  eat_indicator.hide()
