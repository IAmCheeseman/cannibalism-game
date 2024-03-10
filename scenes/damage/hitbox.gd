extends Area2D

signal hit(attack: Attack, hurtbox: Hurtbox)

@export var attack: Attack

func _on_area_entered(area: Area2D) -> void:
  if not area is Hurtbox:
    return
  
  var hurtbox := area as Hurtbox
  hurtbox.take_damage(attack)

  hit.emit(attack, hurtbox)

