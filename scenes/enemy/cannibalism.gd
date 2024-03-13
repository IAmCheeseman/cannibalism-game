extends Area2D

@onready var teeth := $Teeth
@onready var animation := $Teeth/AnimationPlayer

@export var entity: Enemy

func _ready() -> void:
  add_to_group("cannibalism")
  Player.instance.enemy_eaten.connect(_on_enemy_eaten)
  teeth.hide()

func _process(_delta: float) -> void:
  var areas = get_overlapping_areas()
  var player = Player.instance
  if areas.size() == 0:
    teeth.hide()
    if player.eat_target == entity:
      player.eat_target = null
  for area in areas:
    var this_dist = player.global_position.distance_to(entity.global_position)
    var closer = false
    if player.eat_target != null:
      closer = player.global_position.distance_to(player.eat_target.global_position) < this_dist
    if player.can_override_eat_target() and (closer or player.eat_target == null):
      get_tree().call_group("cannibalism", "priority_taken")
      teeth.show()
      Player.instance.eat_target = entity

func _on_enemy_eaten(enemy: Enemy) -> void:
  if enemy == entity:
    remove_child(teeth)
    enemy.add_sibling(teeth)
    teeth.global_position = enemy.global_position
    animation.play("eat")

func priority_taken() -> void:
  teeth.hide()
