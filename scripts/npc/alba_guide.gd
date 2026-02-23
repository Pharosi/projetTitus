extends Node2D

signal dialogue_requested(text: String)
signal sanctuary_activated

@export var area_id: StringName = &"forest_slice"
@export var first_dialogue: String = "Alba: Titus, acenda o Santuario da Aurora para estabilizar esta floresta."
@export var activated_dialogue: String = "Alba: A luz voltou. Siga em frente e enfrente o eco de Aodh."

var player_in_range: bool = false
var sanctuary_is_active: bool = false

@onready var aura: ColorRect = $Aura

func _ready() -> void:
	_update_visuals()

func _process(_delta: float) -> void:
	if not player_in_range:
		return
	if not Input.is_action_just_pressed("interact"):
		return

	if sanctuary_is_active:
		dialogue_requested.emit(activated_dialogue)
		return

	sanctuary_is_active = true
	LightState.set_state(LightState.State.LIT)
	sanctuary_activated.emit()
	dialogue_requested.emit(activated_dialogue)
	_update_visuals()

func _on_interaction_range_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if sanctuary_is_active:
			dialogue_requested.emit(activated_dialogue)
		else:
			dialogue_requested.emit(first_dialogue)

func _on_interaction_range_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _update_visuals() -> void:
	aura.color = Color(1.0, 0.88, 0.62, 0.82) if sanctuary_is_active else Color(0.52, 0.58, 0.72, 0.45)
