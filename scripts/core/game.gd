extends Node2D

@onready var status_label: Label = $CanvasLayer/UIRoot/TopPanel/StatusLabel
@onready var left_panel: ColorRect = $CanvasLayer/UIRoot/LeftPanel
@onready var light_label: Label = $CanvasLayer/UIRoot/LeftPanel/LightLabel
@onready var player_label: Label = $CanvasLayer/UIRoot/LeftPanel/PlayerLabel
@onready var boss_label: Label = $CanvasLayer/UIRoot/BossPanel/BossLabel
@onready var narrative_label: Label = $CanvasLayer/UIRoot/NarrativePanel/NarrativeLabel
@onready var player_health_bar: ProgressBar = $CanvasLayer/UIRoot/LeftPanel/PlayerHealthBar
@onready var boss_health_bar: ProgressBar = $CanvasLayer/UIRoot/BossPanel/BossHealthBar
@onready var light_state_bar: ProgressBar = $CanvasLayer/UIRoot/LeftPanel/LightStateBar
@onready var scene_light_overlay: ColorRect = $CanvasLayer/UIRoot/SceneLightOverlay

@onready var spawn_marker: Marker2D = $ForestSlice/Spawn
@onready var titus: Node2D = $Titus
@onready var alba: Node = $ForestSlice/Alba
@onready var aodh_echo: Node = $ForestSlice/AodhEcho

var narrative_timeout_left: float = 0.0
var light_tween: Tween

enum NarrativePriority {
	LOW = 0,
	MEDIUM = 1,
	HIGH = 2
}

var current_narrative_priority: int = NarrativePriority.LOW
var last_boss_dialogue: String = ""
var boss_dialogue_cooldown_left: float = 0.0

func _ready() -> void:
	titus.global_position = spawn_marker.global_position

	LightState.light_state_changed.connect(_on_light_state_changed)
	if titus.has_signal("health_changed"):
		titus.health_changed.connect(_on_player_health_changed)
	if titus.has_signal("player_defeated"):
		titus.player_defeated.connect(_on_player_defeated)
	if aodh_echo.has_signal("boss_health_changed"):
		aodh_echo.boss_health_changed.connect(_on_boss_health_changed)
	if aodh_echo.has_signal("boss_dialogue"):
		aodh_echo.boss_dialogue.connect(_on_boss_dialogue)
	if aodh_echo.has_signal("boss_defeated"):
		aodh_echo.boss_defeated.connect(_on_boss_defeated)
	if alba.has_signal("dialogue_requested"):
		alba.dialogue_requested.connect(_on_alba_dialogue)
	if alba.has_signal("sanctuary_activated"):
		alba.sanctuary_activated.connect(_on_sanctuary_activated)

	status_label.text = "WASD/Setas: mover | Espaco: pular | Shift: dash | J: melee | E: interagir com Alba | L: ciclo da luz"
	LightState.enter_area(&"forest_slice")
	_sync_player_hud()
	_sync_boss_hud()
	_show_narrative("Alba: Titus, encontre o santuario e estabilize a luz da floresta.", NarrativePriority.HIGH, 4.6)

func _process(delta: float) -> void:
	boss_dialogue_cooldown_left = max(boss_dialogue_cooldown_left - delta, 0.0)

	if narrative_timeout_left == 0.0:
		return
	narrative_timeout_left = max(narrative_timeout_left - delta, 0.0)
	if narrative_timeout_left == 0.0:
		narrative_label.text = ""
		current_narrative_priority = NarrativePriority.LOW

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("light_action"):
		LightState.cycle_state()

func _on_light_state_changed(_area_id: StringName, light_state: int) -> void:
	light_label.text = "Estado: %s" % LightState.get_state_name()
	_animate_light_feedback(light_state)

func _on_player_health_changed(current: int, maximum: int) -> void:
	player_label.text = "HP %d/%d" % [current, maximum]
	player_health_bar.max_value = float(maximum)
	player_health_bar.value = float(current)

func _on_boss_health_changed(current: int, maximum: int) -> void:
	boss_label.text = "HP %d/%d" % [current, maximum]
	boss_health_bar.max_value = float(maximum)
	boss_health_bar.value = float(current)

func _on_player_defeated() -> void:
	titus.global_position = spawn_marker.global_position
	if titus.has_method("restore_health"):
		titus.restore_health()
	_show_narrative("Alba: Levante-se, Titus. A luz ainda precisa de voce.", NarrativePriority.HIGH, 4.8)

func _on_boss_defeated() -> void:
	boss_label.text = "Derrotado"
	boss_health_bar.value = 0.0
	_show_narrative("Alba: Voce restaurou a aurora desta regiao.", NarrativePriority.HIGH, 4.8)

func _on_sanctuary_activated() -> void:
	_show_narrative("Santuario ativado. A luz envolveu a floresta.", NarrativePriority.HIGH, 4.2)

func _show_narrative(text: String, priority: int = NarrativePriority.MEDIUM, duration: float = 4.2) -> void:
	if narrative_timeout_left > 0.0 and priority < current_narrative_priority:
		return

	current_narrative_priority = priority
	narrative_label.text = text
	narrative_timeout_left = duration

func _sync_player_hud() -> void:
	if not titus.has_method("get"):
		return

	var current: int = int(titus.get("current_health"))
	var maximum: int = int(titus.get("max_health"))
	_on_player_health_changed(current, maximum)

func _sync_boss_hud() -> void:
	if not aodh_echo.has_method("get"):
		return

	var current: int = int(aodh_echo.get("current_health"))
	var maximum: int = int(aodh_echo.get("max_health"))
	_on_boss_health_changed(current, maximum)

func _animate_light_feedback(light_state: int) -> void:
	var overlay_color: Color = Color(0.05, 0.09, 0.14, 0.26)
	var panel_color: Color = Color(0.04, 0.09, 0.12, 0.80)
	var label_color: Color = Color(1.0, 1.0, 1.0, 1.0)
	var bar_tint: Color = Color(0.55, 0.65, 0.92, 1.0)

	match light_state:
		LightState.State.DARK:
			overlay_color = Color(0.03, 0.06, 0.10, 0.34)
			panel_color = Color(0.03, 0.07, 0.11, 0.88)
			label_color = Color(0.82, 0.89, 1.0, 1.0)
			bar_tint = Color(0.48, 0.60, 0.94, 1.0)
		LightState.State.UNSTABLE:
			overlay_color = Color(0.14, 0.11, 0.06, 0.24)
			panel_color = Color(0.12, 0.10, 0.08, 0.86)
			label_color = Color(1.0, 0.93, 0.78, 1.0)
			bar_tint = Color(0.95, 0.76, 0.30, 1.0)
		LightState.State.LIT:
			overlay_color = Color(0.30, 0.25, 0.12, 0.14)
			panel_color = Color(0.14, 0.13, 0.08, 0.82)
			label_color = Color(1.0, 0.98, 0.88, 1.0)
			bar_tint = Color(1.0, 0.88, 0.30, 1.0)

	if light_tween != null:
		light_tween.kill()

	light_tween = create_tween()
	light_tween.set_trans(Tween.TRANS_SINE)
	light_tween.set_ease(Tween.EASE_IN_OUT)
	light_tween.parallel().tween_property(scene_light_overlay, "color", overlay_color, 0.35)
	light_tween.parallel().tween_property(left_panel, "color", panel_color, 0.35)
	light_tween.parallel().tween_property(light_label, "modulate", label_color, 0.35)
	light_tween.parallel().tween_property(light_state_bar, "value", float(light_state), 0.28)
	light_tween.parallel().tween_property(light_state_bar, "modulate", bar_tint, 0.35)

func _on_boss_dialogue(text: String) -> void:
	if text == last_boss_dialogue:
		return
	if boss_dialogue_cooldown_left > 0.0:
		return

	last_boss_dialogue = text
	boss_dialogue_cooldown_left = 1.1
	_show_narrative(text, NarrativePriority.LOW, 2.8)

func _on_alba_dialogue(text: String) -> void:
	_show_narrative(text, NarrativePriority.HIGH, 4.4)
