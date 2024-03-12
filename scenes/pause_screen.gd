extends Control

func _ready() -> void:
  hide()

func _input(event: InputEvent) -> void:
  if event.is_action_pressed("pause"):
    get_tree().paused = not get_tree().paused
    visible = get_tree().paused
