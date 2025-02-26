extends Node2D


func _input(event: InputEvent) -> void:
	handle_exit_input()
	#handle_pause_input();
	handle_window_mode_input()

func handle_exit_input() -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

func handle_window_mode_input() -> void:
	if Input.is_action_just_pressed("toggle_full_screen"):
		var mode = DisplayServer.window_get_mode()
		if mode != DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
