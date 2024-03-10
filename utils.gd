extends Resource
class_name Utils

static func delta_lerp(a, b, t: float, delta: float):
  return lerp(b, a, pow(0.5, (delta * t)))
