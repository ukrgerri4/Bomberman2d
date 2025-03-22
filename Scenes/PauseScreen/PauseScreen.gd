class_name PauseScreen
extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport().get_visible_rect().size
	get_tree().paused = true

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_settings_button_pressed() -> void:
	SceneManager.swap_scenes(ResourceManager.settings_screen_scene_path, get_node("/root/Main"), null, "no_transition")

func _on_exit_button_pressed() -> void:
	GameEvents.exit_game_pressed.emit()
