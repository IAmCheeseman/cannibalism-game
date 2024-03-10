extends RefCounted
class_name State

var name: String
var enter
var process
var exit

func _init(_name: String, _enter, _process, _exit) -> void:
  name = _name
  enter = _enter
  process = _process
  exit = _exit
