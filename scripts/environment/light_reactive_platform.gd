extends StaticBody2D

@export var area_id: StringName = &"test_room"

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var visual: ColorRect = $PlatformVisual

func _ready() -> void:
	LightState.light_state_changed.connect(_apply_state)
	_apply_state(LightState.current_area_id, LightState.current_state)

func _apply_state(_area_id: StringName, light_state: int) -> void:
	if _area_id != area_id:
		return

	match light_state:
		LightState.State.DARK:
			collision.disabled = true
			visual.visible = false
		LightState.State.UNSTABLE:
			collision.disabled = false
			visual.visible = true
			visual.modulate = Color(0.96, 0.8, 0.45, 0.5)
		LightState.State.LIT:
			collision.disabled = false
			visual.visible = true
			visual.modulate = Color(1.0, 0.9, 0.45, 1.0)
