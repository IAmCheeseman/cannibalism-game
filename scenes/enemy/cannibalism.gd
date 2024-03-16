extends Area2D

@onready var teeth := $Teeth

@export var entity: Enemy
@export var health: Health

const TEETH_ANIMATION = preload("res://scenes/effects/teeth.tscn")

func _ready() -> void:
  Player.instance.enemy_eaten.connect(_on_enemy_eaten)
  teeth.hide()

func _process(_delta: float) -> void:
  var areas = get_overlapping_areas()
  var player = Player.instance
  if areas.size() == 0:
    teeth.hide()
    # if this is ours
    if player.eat_target == entity:
      player.eat_target = null

  if not player.can_override_eat_target():
    return

  for area in areas:
    var this_dist = player.global_position.distance_to(entity.global_position)
    var closer = false
    if player.eat_target != null:
      closer = player.global_position.distance_to(player.eat_target.global_position) < this_dist
    if closer or player.eat_target == null:
      get_tree().call_group("cannibalism", "priority_taken")
      teeth.show()
      Player.instance.eat_target = entity

func _on_enemy_eaten(enemy: Enemy) -> void:
  if enemy == entity:
    teeth.hide()
    var teeth_animation = TEETH_ANIMATION.instantiate()
    teeth_animation.global_position = global_position
    enemy.add_sibling(teeth_animation)

func priority_taken() -> void:
  teeth.hide()
