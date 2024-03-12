extends Control

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var stamina_label: Label = %StaminaLabel
@onready var level_label: Label = %LevelLabel

@export var health: Health

func _ready() -> void:
  Player.instance.stamina_changed.connect(_update_stamina)
  health.took_damage.connect(_update_health)
  level_label.text = "Level #%d" % [LevelManager.level]
  _update_health()

func _update_stamina(stamina) -> void:
  stamina_bar.value = stamina
  stamina_label.text = "%d/100" % [floor(stamina)]

func _update_health() -> void:
  health_label.text = "%d/%d" % [health.health, health.max_health]
  health_bar.max_value = health.max_health
  health_bar.value = health.health
