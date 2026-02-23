extends Node2D

@onready var status_label: Label = $CanvasLayer/UIRoot/StatusLabel
@onready var spawn_marker: Marker2D = $TestRoom/Spawn
@onready var titus: CharacterBody2D = $Titus

func _ready() -> void:
	titus.global_position = spawn_marker.global_position
	status_label.text = "WASD/Setas: mover | Espaco: pular | Shift: dash | J: ataque melee | E: interagir"
