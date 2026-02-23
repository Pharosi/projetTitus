extends CharacterBody2D

signal boss_health_changed(current: int, maximum: int)
signal boss_defeated
signal boss_dialogue(text: String)

@export var area_id: StringName = &"forest_slice"
@export var max_health: int = 12
@export var chase_speed_dark: float = 190.0
@export var chase_speed_unstable: float = 145.0
@export var chase_speed_lit: float = 105.0
@export var contact_damage: int = 1
@export var attack_cooldown: float = 0.9

var current_health: int
var move_speed: float = 140.0
var damage_cooldown_left: float = 0.0
var is_defeated: bool = false

@onready var left_bound: Marker2D = $ArenaBounds/Left
@onready var right_bound: Marker2D = $ArenaBounds/Right
@onready var body_visual: ColorRect = $BodyVisual

func _ready() -> void:
	current_health = max_health
	LightState.light_state_changed.connect(_on_light_state_changed)
	_on_light_state_changed(LightState.current_area_id, LightState.current_state)
	boss_health_changed.emit(current_health, max_health)

func _physics_process(delta: float) -> void:
	if is_defeated:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	damage_cooldown_left = max(damage_cooldown_left - delta, 0.0)

	var player: CharacterBody2D = _get_player()
	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir_x: float = sign(player.global_position.x - global_position.x)
	velocity.x = dir_x * move_speed
	velocity.y = 0.0
	move_and_slide()

	global_position.x = clamp(global_position.x, left_bound.global_position.x, right_bound.global_position.x)

	if damage_cooldown_left == 0.0 and global_position.distance_to(player.global_position) < 46.0:
		damage_cooldown_left = attack_cooldown
		if player.has_method("receive_damage"):
			player.receive_damage(contact_damage, global_position.x)

func apply_melee_hit(damage: int, source_position: Vector2) -> void:
	if is_defeated:
		return

	current_health = max(current_health - damage, 0)
	boss_health_changed.emit(current_health, max_health)

	var knockback_dir: float = sign(global_position.x - source_position.x)
	global_position.x += knockback_dir * 14.0

	if current_health <= 0:
		is_defeated = true
		body_visual.color = Color(0.65, 0.65, 0.65, 0.65)
		boss_dialogue.emit("Eco de Aodh: A chama... se apaga...")
		boss_defeated.emit()

func _on_light_state_changed(changed_area_id: StringName, light_state: int) -> void:
	if changed_area_id != area_id:
		return

	match light_state:
		LightState.State.DARK:
			move_speed = chase_speed_dark
			body_visual.color = Color(0.84, 0.2, 0.16, 1.0)
			boss_dialogue.emit("Eco de Aodh: Na escuridao, meu fogo devora tudo.")
		LightState.State.UNSTABLE:
			move_speed = chase_speed_unstable
			body_visual.color = Color(0.88, 0.42, 0.18, 1.0)
			boss_dialogue.emit("Eco de Aodh: A luz vacila, Titus.")
		LightState.State.LIT:
			move_speed = chase_speed_lit
			body_visual.color = Color(0.95, 0.72, 0.28, 1.0)
			boss_dialogue.emit("Eco de Aodh: Esta luz enfraquece minha furia...")

func _get_player() -> CharacterBody2D:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as CharacterBody2D
