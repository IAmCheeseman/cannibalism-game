extends Sprite2D

var time := randf() * TAU

func _process(delta: float) -> void:
  time = time + delta
  skew = sin(time) * 0.1
