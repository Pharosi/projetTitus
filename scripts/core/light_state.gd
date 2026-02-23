extends Node

signal light_state_changed(area_id: StringName, new_state: int)

enum State {
	DARK,
	UNSTABLE,
	LIT
}

const DEFAULT_AREA: StringName = &"global"

var current_area_id: StringName = DEFAULT_AREA
var area_states: Dictionary = {
	DEFAULT_AREA: State.DARK
}

var current_state: State:
	get:
		return int(area_states.get(current_area_id, State.DARK))

func set_state(next_state: State) -> void:
	if current_state == next_state:
		return
	area_states[current_area_id] = next_state
	light_state_changed.emit(current_area_id, next_state)

func cycle_state() -> void:
	var next_state: State = (int(current_state) + 1) % 3
	set_state(next_state)

func enter_area(area_id: StringName) -> void:
	current_area_id = area_id
	if not area_states.has(current_area_id):
		area_states[current_area_id] = State.DARK
	light_state_changed.emit(current_area_id, current_state)

func get_state_name() -> String:
	match current_state:
		State.DARK:
			return "Escuridao"
		State.UNSTABLE:
			return "Instavel"
		State.LIT:
			return "Iluminada"
		_:
			return "Desconhecido"
