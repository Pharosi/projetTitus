extends CharacterBody2D

@export var run_speed: float = 240.0
@export var acceleration: float = 1400.0
@export var deacceleration: float = 1700.0
@export var jump_velocity: float = -430.0
@export var wall_jump_push: float = 260.0
@export var max_fall_speed: float = 900.0
@export var wall_slide_speed: float = 110.0
@export var wall_slide_gravity_factor: float = 0.18
@export var dash_speed: float = 540.0
@export var dash_duration: float = 0.16
@export var dash_cooldown: float = 0.42
@export var melee_active_time: float = 0.14
@export var melee_cooldown: float = 0.30

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float
var facing: int = 1
var dash_direction: int = 1
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var melee_time_left: float = 0.0
var melee_cooldown_left: float = 0.0

@onready var attack_pivot: Node2D = $AttackPivot
@onready var body_visual: Polygon2D = $BodyVisual
@onready var melee_collision: CollisionShape2D = $AttackPivot/MeleeArea/CollisionShape2D

func _ready() -> void:
	melee_collision.disabled = true
	_update_facing(1.0)

func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_handle_melee_input()

	var axis: float = Input.get_axis("move_left", "move_right")
	if axis != 0.0:
		_update_facing(axis)

	if _try_start_dash(axis):
		move_and_slide()
		return

	if dash_time_left > 0.0:
		velocity = Vector2(float(dash_direction) * dash_speed, 0.0)
		move_and_slide()
		return

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif is_on_wall_only():
			velocity.y = jump_velocity * 0.92
			velocity.x = -get_wall_normal().x * wall_jump_push

	var target_speed: float = axis * run_speed
	var accel: float = acceleration if axis != 0.0 else deacceleration
	velocity.x = move_toward(velocity.x, target_speed, accel * delta)

	if _is_wall_clinging(axis):
		velocity.y += gravity * wall_slide_gravity_factor * delta
		velocity.y = min(velocity.y, wall_slide_speed)
	else:
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)

	move_and_slide()

func _try_start_dash(axis: float) -> bool:
	if not Input.is_action_just_pressed("dash"):
		return false
	if dash_cooldown_left > 0.0:
		return false

	dash_direction = facing
	if axis != 0.0:
		dash_direction = int(sign(axis))

	dash_time_left = dash_duration
	dash_cooldown_left = dash_cooldown
	velocity.y = 0.0
	velocity.x = float(dash_direction) * dash_speed
	return true

func _is_wall_clinging(axis: float) -> bool:
	if is_on_floor():
		return false
	if not is_on_wall_only():
		return false
	if velocity.y < 0.0:
		return false

	var wall_normal: Vector2 = get_wall_normal()
	return axis != 0.0 and sign(axis) == sign(-wall_normal.x)

func _handle_melee_input() -> void:
	if not Input.is_action_just_pressed("attack_melee"):
		return
	if melee_cooldown_left > 0.0:
		return

	melee_time_left = melee_active_time
	melee_cooldown_left = melee_cooldown
	melee_collision.disabled = false

func _update_timers(delta: float) -> void:
	dash_time_left = max(dash_time_left - delta, 0.0)
	dash_cooldown_left = max(dash_cooldown_left - delta, 0.0)
	melee_time_left = max(melee_time_left - delta, 0.0)
	melee_cooldown_left = max(melee_cooldown_left - delta, 0.0)

	if melee_time_left == 0.0 and not melee_collision.disabled:
		melee_collision.disabled = true

func _update_facing(axis: float) -> void:
	facing = 1 if axis > 0.0 else -1
	body_visual.scale.x = float(facing)
	attack_pivot.position.x = 20.0 * float(facing)
