extends Node2D

@onready var status_label: Label = $CanvasLayer/UIRoot/TopPanel/StatusLabel
@onready var light_label: Label = $CanvasLayer/UIRoot/LeftPanel/LightLabel
@onready var player_label: Label = $CanvasLayer/UIRoot/LeftPanel/PlayerLabel
@onready var boss_label: Label = $CanvasLayer/UIRoot/BossPanel/BossLabel
@onready var narrative_label: Label = $CanvasLayer/UIRoot/NarrativePanel/NarrativeLabel
@onready var player_health_bar: ProgressBar = $CanvasLayer/UIRoot/LeftPanel/PlayerHealthBar
@onready var boss_health_bar: ProgressBar = $CanvasLayer/UIRoot/BossPanel/BossHealthBar
@onready var light_state_bar: ProgressBar = $CanvasLayer/UIRoot/LeftPanel/LightStateBar

@onready var spawn_marker: Marker2D = $ForestSlice/Spawn
@onready var titus: Node2D = $Titus
@onready var alba: Node = $ForestSlice/Alba
@onready var aodh_echo: Node = $ForestSlice/AodhEcho

var narrative_timeout_left: float = 0.0

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
		aodh_echo.boss_dialogue.connect(_show_narrative)
	if aodh_echo.has_signal("boss_defeated"):
		aodh_echo.boss_defeated.connect(_on_boss_defeated)
	if alba.has_signal("dialogue_requested"):
		alba.dialogue_requested.connect(_show_narrative)
	if alba.has_signal("sanctuary_activated"):
		alba.sanctuary_activated.connect(_on_sanctuary_activated)

	status_label.text = "WASD/Setas: mover | Espaco: pular | Shift: dash | J: melee | E: interagir com Alba | L: ciclo da luz"
	LightState.enter_area(&"forest_slice")
	_sync_player_hud()
	_sync_boss_hud()
	_show_narrative("Alba: Titus, encontre o santuario e estabilize a luz da floresta.")

func _process(delta: float) -> void:
	if narrative_timeout_left == 0.0:
		return
	narrative_timeout_left = max(narrative_timeout_left - delta, 0.0)
	if narrative_timeout_left == 0.0:
		narrative_label.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("light_action"):
		LightState.cycle_state()

func _on_light_state_changed(_area_id: StringName, light_state: int) -> void:
	light_label.text = "Estado: %s" % LightState.get_state_name()
	light_state_bar.value = float(light_state)

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
	_show_narrative("Alba: Levante-se, Titus. A luz ainda precisa de voce.")

func _on_boss_defeated() -> void:
	boss_label.text = "Derrotado"
	boss_health_bar.value = 0.0
	_show_narrative("Alba: Voce restaurou a aurora desta regiao.")

func _on_sanctuary_activated() -> void:
	_show_narrative("Santuario ativado. A luz envolveu a floresta.")

func _show_narrative(text: String) -> void:
	narrative_label.text = text
	narrative_timeout_left = 4.2

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
