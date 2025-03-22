class_name MainScreen
extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport().get_visible_rect().size
	$VBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	#$PanelContainer/SettingsButton.pressed.connect()
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)

func _on_exit_button_pressed() -> void:
	GameEvents.exit_game_pressed.emit()

func _on_start_button_pressed() -> void:
	SceneManager.swap_scenes(ResourceManager.game_scene_path, get_node("/root/Main"), self, "no_transition")
