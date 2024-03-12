extends Control

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var stamina_bar: ProgressBar = %StaminaBar

@export var health: Health

func _ready() -> void:
  health.took_damage.connect(_update_health)
  _update_health()

func _process(delta: float) -> void:
  stamina_bar.value = Player.instance.stamina

func _update_health() -> void:
  health_label.text = "%d/%d" % [health.health, health.max_health]
  health_bar.max_value = health.max_health
  health_bar.value = health.health
