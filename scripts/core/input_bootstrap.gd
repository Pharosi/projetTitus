extends Node

const ACTIONS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"move_up": [KEY_W, KEY_UP],
	"move_down": [KEY_S, KEY_DOWN],
	"jump": [KEY_SPACE],
	"dash": [KEY_SHIFT],
	"attack_melee": [KEY_J],
	"attack_ranged": [KEY_K],
	"light_action": [KEY_L],
	"interact": [KEY_E]
}

func _ready() -> void:
	for action_name: String in ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		for keycode: Key in ACTIONS[action_name]:
			if _action_has_key(action_name, keycode):
				continue

			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action_name, event)

func _action_has_key(action_name: String, keycode: Key) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if event is InputEventKey and event.physical_keycode == keycode:
			return true
	return false
