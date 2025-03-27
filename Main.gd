extends Node2D

@onready var splash_screen: SplashScreen = $SplashScreen

var _is_game_started := false

func _ready() -> void:
	GameEvents.exit_game_pressed.connect(_on_exit_game_pressed)
	GameEvents.game_started.connect(_on_game_started)
	GameEvents.game_ended.connect(_on_game_ended)

func _input(_event: InputEvent) -> void:
	_handle_exit_input()
	_handle_pause_input()
	_handle_window_mode_input()

func _handle_exit_input() -> void:
	if Input.is_action_just_pressed("exit"):
		if _is_game_started:
			if !get_tree().paused:
				_show_pause_screen()
		else:
			_on_exit_game_pressed()

func _handle_pause_input() -> void:
	if Input.is_action_just_pressed("pause") && _is_game_started && !get_tree().paused:
		_show_pause_screen()

func _handle_window_mode_input() -> void:
	if Input.is_action_just_pressed("toggle_full_screen"):
		var mode = DisplayServer.window_get_mode()
		if mode != DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _show_pause_screen() -> void:
	SceneManager.swap_scenes(ResourceManager.pause_screen_scene_path, get_node("/root/Main"), null, "no_transition")

func _on_splash_screen_animation_finished() -> void:
	SceneManager.swap_scenes(ResourceManager.main_screen_scene_path, get_node("/root/Main"), splash_screen, "no_transition")

func _on_exit_game_pressed() -> void:
	get_tree().quit()

func _on_game_started() -> void:
	_is_game_started = true

func _on_game_ended() -> void:
	_is_game_started = false
