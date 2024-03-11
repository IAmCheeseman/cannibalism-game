extends Node2D

@onready var vortex: Sprite2D = $VortexFront
@onready var loading_zone: Area2D = $LoadingZone

@export var world_generator: WorldGenerator

var enemy_count := 0

func _ready() -> void:
  world_generator.enemy_spawned.connect(_on_enemy_spawned)

func _on_enemy_spawned(enemy) -> void:
  var enemy_health = enemy.get_node("Health")
  enemy_health.died.connect(_on_enemy_died)
  enemy_count += 1

func _on_enemy_died() -> void:
  enemy_count -= 1

  if enemy_count <= 0:
    loading_zone.monitoring = true
    vortex.visible = true

func _on_loading_zone_entered(_area: Area2D) -> void:
  get_tree().call_deferred("reload_current_scene")
