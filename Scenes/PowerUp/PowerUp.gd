class_name PowerUp
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var type: Constants.PowerUpType

func _ready() -> void:
	match type:
		Constants.PowerUpType.EXTRA_BOMB:
			sprite.texture = ResourceManager.power_up_extra_bomb_texture
		Constants.PowerUpType.BLAST_INCREASE:
			sprite.texture = ResourceManager.power_up_blast_radius_texture
		Constants.PowerUpType.SPEED_INCREASE:
			sprite.texture = ResourceManager.power_up_speed_increase_texture

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		match type:
			Constants.PowerUpType.EXTRA_BOMB:
				(body as Player).replenish_bombs()
			Constants.PowerUpType.BLAST_INCREASE:
				(body as Player).increase_blast_length()
			Constants.PowerUpType.SPEED_INCREASE:
				(body as Player).increase_speed()
		queue_free()
