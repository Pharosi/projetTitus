extends Node2D

@onready var status_label: Label = $CanvasLayer/UIRoot/StatusLabel
@onready var spawn_marker: Marker2D = $TestRoom/Spawn
@onready var titus: CharacterBody2D = $Titus

func _ready() -> void:
	titus.global_position = spawn_marker.global_position
	LightState.light_state_changed.connect(_refresh_status)
	LightState.enter_area(&"test_room")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("light_action"):
		LightState.cycle_state()

func _refresh_status(_area_id: StringName, _light_state: int) -> void:
	status_label.text = "WASD/Setas: mover | Espaco: pular | Shift: dash | J: melee | L: ciclo da luz (%s)" % LightState.get_state_name()
