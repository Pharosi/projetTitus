extends Node2D

@onready var status_label: Label = $CanvasLayer/UIRoot/StatusLabel

func _ready() -> void:
	status_label.text = "Bootstrap Godot 4 pronto. Proxima etapa: controller do Titus."
