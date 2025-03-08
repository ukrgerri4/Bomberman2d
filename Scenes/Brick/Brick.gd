class_name Brick
extends CharacterBody2D

const DEFAULT_ANIMATION_NAME: String = "default"
const DESTRUCTION_ANIMATION_NAME: String = "destruction"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var map_position: Vector2

var _is_destructing: bool = false

func _ready() -> void:
	animated_sprite.animation = DEFAULT_ANIMATION_NAME
	GameEvents.bomb_hit.connect(_on_brick_hit)

func _destruct() -> void:
	animated_sprite.animation = DESTRUCTION_ANIMATION_NAME
	animated_sprite.play()

func _on_animated_sprite_2d_animation_finished() -> void:
	GameEvents.brick_destroyed.emit(map_position)
	queue_free()

func _on_brick_hit(node: Node2D) -> void:
	if node is Brick and node == self and !_is_destructing:
		_is_destructing = true
		_destruct.call_deferred()
