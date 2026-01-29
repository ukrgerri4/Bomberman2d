extends Node

const CONFIG_FILE_PATH := "user://settings.ini"

var config := ConfigFile.new()

func _ready() -> void:
	if !FileAccess.file_exists(CONFIG_FILE_PATH):
		config.set_value("video", "fullscreen", false)
		config.set_value("audio", "master_volume", 1.0)
		config.save(CONFIG_FILE_PATH)
	else:
		config.load(CONFIG_FILE_PATH)
