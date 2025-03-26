class_name SplashScreen
extends Control

signal animation_finished()

const ANIMATION_NAME: StringName = "default"

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	_animation_player.play(ANIMATION_NAME)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == ANIMATION_NAME:
		animation_finished.emit()
