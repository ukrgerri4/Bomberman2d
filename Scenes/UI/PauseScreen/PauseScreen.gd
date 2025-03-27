class_name PauseScreen
extends Screen

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport().get_visible_rect().size
	get_tree().paused = true
	%ContinueButton.pressed.connect(_on_continue_button_pressed)
	%RestartButton.pressed.connect(_on_restart_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%ExitButton.pressed.connect(_on_exit_button_pressed)
	%ContinueButton.grab_focus()

func _exit_tree() -> void:
	get_tree().paused = false

func _on_continue_button_pressed() -> void:
	queue_free()

func _on_restart_button_pressed() -> void:
	var current_game = get_node("/root/Main/Game")
	current_game.queue_free()
	SceneManager.swap_scenes(ResourceManager.game_scene_path, get_node("/root/Main"), null, "no_transition")
	queue_free()

func _on_settings_button_pressed() -> void:
	SceneManager.swap_scenes(ResourceManager.settings_screen_scene_path, get_node("/root/Main"), null, "no_transition")
	recursive_release_focus()

func _on_exit_button_pressed() -> void:
	GameEvents.exit_game_pressed.emit()
