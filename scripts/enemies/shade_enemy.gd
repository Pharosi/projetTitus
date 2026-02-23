extends CharacterBody2D

@export var area_id: StringName = &"test_room"
@export var patrol_speed_dark: float = 170.0
@export var patrol_speed_unstable: float = 115.0
@export var patrol_speed_lit: float = 70.0

var patrol_direction: int = 1
var patrol_speed: float = 120.0

@onready var point_left: Marker2D = $PatrolPoints/Left
@onready var point_right: Marker2D = $PatrolPoints/Right
@onready var body_visual: ColorRect = $BodyVisual

func _ready() -> void:
	LightState.light_state_changed.connect(_on_light_state_changed)
	_on_light_state_changed(LightState.current_area_id, LightState.current_state)

func _physics_process(_delta: float) -> void:
	velocity = Vector2(float(patrol_direction) * patrol_speed, 0.0)
	move_and_slide()

	if global_position.x <= point_left.global_position.x:
		global_position.x = point_left.global_position.x
		patrol_direction = 1
	elif global_position.x >= point_right.global_position.x:
		global_position.x = point_right.global_position.x
		patrol_direction = -1

func _on_light_state_changed(changed_area_id: StringName, light_state: int) -> void:
	if changed_area_id != area_id:
		return

	match light_state:
		LightState.State.DARK:
			patrol_speed = patrol_speed_dark
			body_visual.color = Color(0.7, 0.15, 0.2, 1.0)
		LightState.State.UNSTABLE:
			patrol_speed = patrol_speed_unstable
			body_visual.color = Color(0.75, 0.45, 0.2, 1.0)
		LightState.State.LIT:
			patrol_speed = patrol_speed_lit
			body_visual.color = Color(0.4, 0.75, 0.4, 1.0)
