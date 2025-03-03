class_name Player
extends CharacterBody2D


var _color: Constants.PlayerColor = Constants.PlayerColor.WHITE
var _deviceId: int = -1

var _speed = 50.0
var _is_dead: bool = false
var _direction: Vector2 = Vector2.ZERO
var _place_bomb_delay: float = 0.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite_2d: Sprite2D = $Sprite2D

func initialize(color: Constants.PlayerColor, deviceId: int) -> void:
	_color = color
	_deviceId = deviceId


func _ready() -> void:
	GameEvents.player_hit.connect(_on_player_hit)
	var texture = ResourceManager.get_texture(_color)
	sprite_2d.texture = texture


func _process(delta: float) -> void:
	_handle_bomb_placement(delta)
	_update_animation()


func _exit_tree():
	if GameEvents.player_hit.is_connected(_on_player_hit):
		GameEvents.player_hit.disconnect(_on_player_hit)


func _physics_process(delta: float) -> void:
	_handle_movement(delta)


func _handle_bomb_placement(delta: float) -> void:
	_place_bomb_delay += delta
	if _deviceId == -1:
		if Input.is_action_pressed("place_bomb") and _place_bomb_delay > 0.25:
			_place_bomb()
	else:
		if Input.is_joy_button_pressed(_deviceId, JOY_BUTTON_A) and _place_bomb_delay > 0.25:
			_place_bomb()


func _place_bomb() -> void: # TODO: move to some service
	var p = Vector2(
		ceil(global_position.x / 16.0) * 16 - 8,
		ceil(global_position.y / 16.0) * 16 - 8
	)
	#print_debug("Should palce bomb, position: {0}, {1}".format([global_position, p]))
	var bomb = ResourceManager.bomb_scene.instantiate()
	var container = get_node("/root/Main/Game/BombContainer")
	container.add_child(bomb)
	bomb.global_position = p
	_place_bomb_delay = 0.0


func _handle_movement(delta: float) -> void:
	var new_direction = get_current_direction()
	var x: float = new_direction.x
	var y: float = new_direction.y
	
	if (abs(x) == abs(y) && x != 0 && y != 0):
		x = x if abs(_direction.x) > abs(_direction.y) else 0.0
		y = y if abs(_direction.y) > abs(_direction.x) else 0.0
	
	_direction = Vector2(
		x if abs(x) > abs(y) else 0.0,
		y if abs(y) > abs(x) else 0.0
	).normalized()
	
	if not _direction.is_zero_approx():
		velocity = _direction * _speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()


func get_current_direction() -> Vector2:
	if _deviceId == -1:
		return Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")
		)
	else:
		var direction = Vector2(
			Input.get_joy_axis(_deviceId, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(_deviceId, JOY_AXIS_LEFT_Y),
		)
		
		# this section allows player to use joy dpad arrows to move
		if direction.is_zero_approx() or direction.length_squared() <= 0.05:
			direction = Vector2(
				_get_joy_dpad_axis_x(),
				_get_joy_dpad_axis_y()
			)
			
			if direction.is_zero_approx() or direction.length_squared() <= 0.05:
				return Vector2.ZERO;
			
		return direction


func _get_joy_dpad_axis_x() -> float:
	var negative_action = -1 if Input.is_joy_button_pressed(_deviceId, JOY_BUTTON_DPAD_LEFT) else 0
	var positive_action = 1 if Input.is_joy_button_pressed(_deviceId, JOY_BUTTON_DPAD_RIGHT) else 0
	return negative_action + positive_action


func _get_joy_dpad_axis_y() -> float:
	var negative_action = -1 if Input.is_joy_button_pressed(_deviceId, JOY_BUTTON_DPAD_UP) else 0
	var positive_action = 1 if Input.is_joy_button_pressed(_deviceId, JOY_BUTTON_DPAD_DOWN) else 0
	return negative_action + positive_action


func _update_animation() -> void:
	if (_is_dead):
		animation_tree["parameters/conditions/is_dead"] = _is_dead
		return
	
	animation_tree["parameters/walk/blend_position"] = _direction


func _on_player_hit(player) -> void:
	if player == self:
		_is_dead = true
		set_physics_process(false) # stop player moving
		


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dead":
		#print_debug("Player animation ended: ", anim_name)
		#update_score()
		queue_free()
