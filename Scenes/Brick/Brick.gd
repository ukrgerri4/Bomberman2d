class_name Brick
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.animation = "default"
	GameEvents.bomb_hit.connect(_on_brick_hit)

func _on_brick_hit(node: Node2D) -> void:
	if node is Brick and node == self:
		_destruct.call_deferred()
	
func _destruct() -> void:
	animated_sprite.animation = "destruction"
	animated_sprite.play()

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
