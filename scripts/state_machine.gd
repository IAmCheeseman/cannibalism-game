extends RefCounted
class_name StateMachine

var _current: State

func set_current(state: State) -> void:
  if _current and _current.exit:
    _current.exit.call()
  _current = state
  if _current.enter:
    _current.enter.call()

func get_current_name() -> String:
  return _current.name

func process(delta: float) -> void:
  if _current.process:
    _current.process.call(delta)
