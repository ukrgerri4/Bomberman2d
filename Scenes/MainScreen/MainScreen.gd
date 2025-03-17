class_name MainScreen
extends Control

func _ready() -> void:
	$VBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	#$PanelContainer/SettingsButton.pressed.connect()
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_start_button_pressed() -> void:
	self.visible = false
	SceneManager.swap_scenes("res://Scenes/Game.tscn", get_node("/root/Main"), null, "no_transition")
