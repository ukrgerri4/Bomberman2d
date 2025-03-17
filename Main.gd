extends Node2D

@onready var _splash_screen: SplashScreen = $SplashScreen
@onready var _main_screen: Control = $MainScreen
@onready var _pause_screen: Control = $PauseScreen

func _ready() -> void:
	_splash_screen.visible = true
	_main_screen.visible = false
	_pause_screen.visible = false

func _input(_event: InputEvent) -> void:
	_handle_exit_input()
	_handle_pause_input()
	_handle_window_mode_input()

func _handle_exit_input() -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

func _handle_pause_input() -> void:
	if Input.is_action_just_pressed("pause"):
		var paused = !get_tree().paused
		get_tree().paused = paused
		_pause_screen.visible = paused

func _handle_window_mode_input() -> void:
	if Input.is_action_just_pressed("toggle_full_screen"):
		var mode = DisplayServer.window_get_mode()
		if mode != DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_splash_screen_animation_finished() -> void:
	_splash_screen.visible = false
	_splash_screen.queue_free()
	_main_screen.visible = true
