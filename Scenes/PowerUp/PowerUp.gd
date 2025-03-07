class_name PowerUp
extends Area2D

@onready var sprite: Sprite2D = $Sprite2D

var type: Constants.PowerUpType

func _ready() -> void:
	GameEvents.bomb_hit.connect(_on_hit)
	match type:
		Constants.PowerUpType.EXTRA_BOMB:
			sprite.texture = ResourceManager.power_up_extra_bomb_texture
		Constants.PowerUpType.BLAST_INCREASE:
			sprite.texture = ResourceManager.power_up_blast_radius_texture
		Constants.PowerUpType.SPEED_INCREASE:
			sprite.texture = ResourceManager.power_up_speed_increase_texture

func _exit_tree():
	if GameEvents.bomb_hit.is_connected(_on_hit):
		GameEvents.bomb_hit.disconnect(_on_hit)

func _on_hit(body: Node2D) -> void:
	if body and body == self:
		_burn_power_up()

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

func _burn_power_up():
	if sprite.material and sprite.material is ShaderMaterial:
		var tween = create_tween()
		sprite.material.set_shader_parameter("position", Vector2(0.5, 1.0))
		tween.tween_method(_update_shader_radius, 0.0, 2.0, 1.5)

func _update_shader_radius(value: float):
	if sprite.material:
		sprite.material.set_shader_parameter("radius", value)
