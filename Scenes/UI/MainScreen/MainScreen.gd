class_name MainScreen
extends Screen

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport().get_visible_rect().size
	$VBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_button_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed() -> void:
	SceneManager.swap_scenes(ResourceManager.game_scene_path, get_node("/root/Main"), self, "no_transition")

func _on_settings_button_pressed() -> void:
	SceneManager.swap_scenes(ResourceManager.settings_screen_scene_path, get_node("/root/Main"), null, "no_transition")
	recursive_release_focus()

func _on_exit_button_pressed() -> void:
	GameEvents.exit_game_pressed.emit()
