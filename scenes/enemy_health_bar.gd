extends ProgressBar

@export var health: Health

func _ready() -> void:
  health.took_damage.connect(_on_took_damage)
  _on_took_damage()

func _on_took_damage() -> void:
  value = health.health / health.max_health
