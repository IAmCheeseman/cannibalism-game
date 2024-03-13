extends ColorRect

@export var player: Player

var strength := 0.

func _process(delta: float) -> void:
  var percentage = min(player.stamina / (player.max_stamina / 2), 1)
  strength = Utils.delta_lerp(strength, 1.0 - percentage, 14, delta)
  material.set_shader_parameter("strength", strength)
