class_name Player
extends CharacterBody2D


var _color: Constants.PlayerColor = Constants.PlayerColor.WHITE
var _deviceId: int = -1

var _speed = 50.0
var _is_dead: bool = false
var _direction: Vector2 = Vector2.ZERO

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite_2d: Sprite2D = $Sprite2D

func initialize(color: Constants.PlayerColor, deviceId: int) -> void:
	_color = color
	_deviceId = deviceId

func _ready() -> void:
	var texture = ResourceManager.get_texture(_color)
	sprite_2d.texture = texture

func _process(_delta: float) -> void:
	update_animation()

func _physics_process(_delta: float) -> void:
	var d = get_current_direction()
	var x: float = d.x
	var y: float = d.y
	
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

func update_animation() -> void:
	if (_is_dead):
		animation_tree["parameters/conditions/is_dead"] = _is_dead
		return
	
	animation_tree["parameters/walk/blend_position"] = _direction

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dead":
		print_debug("Player animation ended: ", anim_name)
		#update_score()
		queue_free()
