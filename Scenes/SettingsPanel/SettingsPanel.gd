class_name SettingsPanel
extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport().get_visible_rect().size


func _on_button_pressed() -> void:
	queue_free()
