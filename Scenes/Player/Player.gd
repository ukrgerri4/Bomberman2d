class_name Player
extends CharacterBody2D

const DEAD_ANIMATION_NAME: String = "dead"

var color: Constants.PlayerColor = Constants.PlayerColor.WHITE
var _deviceId: int = -1
var _max_speed: int = 400
var _min_speed: int = 200
var _speed: int = 200
var _speed_increase_duration: int = 10
var _is_dead: bool = false
var _direction: Vector2 = Vector2.ZERO
var _max_bomb_count: int = 5
var _max_blast_length: int = 5
var _bomb_count: int = 0
var _blast_length: int = 1
var _place_bomb_delay: float = 0.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var speed_increase_timer: Timer = $Timer

func initialize(player_color: Constants.PlayerColor, deviceId: int) -> void:
	color = player_color
	_deviceId = deviceId

func _init() -> void:
	GameEvents.bomb_hit.connect(_on_player_hit)
	GameEvents.bomb_expoyded.connect(_on_player_bomb_expoyded)
	GameEvents.extra_bomb_power_up_picked.connect(_on_extra_bomb_power_up_picked)
	GameEvents.increase_blast_length_power_up_picked.connect(_on_increase_blast_length_power_up_picked)
	GameEvents.increase_speed_power_up_picked.connect(_on_increase_speed_power_up_picked)

func _ready() -> void:
	_increase_bomb_count(2)
	var texture = ResourceManager.get_player_texture(color)
	sprite_2d.texture = texture
	speed_increase_timer.timeout.connect(_decrease_speed)

func _process(delta: float) -> void:
	_handle_bomb_placement(delta)
	_update_animation()

func _physics_process(delta: float) -> void:
	_handle_movement(delta)

func _handle_bomb_placement(delta: float) -> void:
	_place_bomb_delay += delta
	if _deviceId == -1:
		if Input.is_action_pressed("place_bomb") and _bomb_count > 0 and _place_bomb_delay > 0.25:
			_place_bomb()
	else:
		if Input.is_joy_button_pressed(_deviceId, JOY_BUTTON_A) and _bomb_count > 0 and _place_bomb_delay > 0.25:
			_place_bomb()

func _place_bomb() -> void: # TODO: move to some service
	var spawn_point = Vector2(
		ceil((global_position.x - MapSettings.OFFSET_LEFT) / MapSettings.BLOCK_SIZE) * MapSettings.BLOCK_SIZE - MapSettings.HALF_BLOCK_SIZE + MapSettings.OFFSET_LEFT,
		ceil((global_position.y - MapSettings.OFFSET_TOP) / MapSettings.BLOCK_SIZE) * MapSettings.BLOCK_SIZE - MapSettings.HALF_BLOCK_SIZE + MapSettings.OFFSET_TOP,
	)
	if _is_bomb_already_placed(spawn_point):
		return
	
	#print_debug("Should palce bomb, position: {0}, {1}".format([global_position, p]))
	var bomb = ResourceManager.bomb_scene.instantiate()
	bomb.player_owner = self
	bomb.explosion_blast_length = _blast_length
	var container = get_node("/root/Main/Game/BombContainer")
	container.add_child(bomb)
	bomb.global_position = spawn_point
	_place_bomb_delay = 0.0
	_decrease_bomb_count(1)

func _is_bomb_already_placed(spawn_point: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query =  PhysicsPointQueryParameters2D.new()
	query.position = spawn_point
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 1 << 1 # bomb
	var result = space_state.intersect_point(query, 1)
	return result.size() > 0

func _handle_movement(_delta: float) -> void:
	var new_direction = _get_current_direction()
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

func _get_current_direction() -> Vector2:
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

func _increase_bomb_count(count: int) -> void:
	_bomb_count += count
	GameEvents.player_bomb_count_changed.emit(color, _bomb_count)

func _decrease_bomb_count(count: int) -> void:
	_bomb_count -= count
	GameEvents.player_bomb_count_changed.emit(color, _bomb_count)

func _decrease_speed() -> void:
	_speed = clampi(_speed - 200, _min_speed, _max_speed)

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == DEAD_ANIMATION_NAME:
		#print_debug("Player animation ended: ", anim_name)
		#update_score()
		GameEvents.player_died.emit(color)
		queue_free()

func _on_player_hit(body: Node2D) -> void:
	if body is Player and body == self:
		_is_dead = true
		set_physics_process(false) # stop player moving

func _on_player_bomb_expoyded(player: Player) -> void:
	if player and player == self:
		if _bomb_count < _max_bomb_count:
			_increase_bomb_count(1)

func _on_extra_bomb_power_up_picked(player: Player) -> void:
	if player and player == self:
		if _bomb_count < _max_bomb_count:
			_increase_bomb_count(1)
	
func _on_increase_blast_length_power_up_picked(player: Player) -> void:
	if player and player == self:
		if _blast_length < _max_blast_length:
			_blast_length += 1
		
func _on_increase_speed_power_up_picked(player: Player) -> void:
	if player and player == self:
		_speed = clampi(_speed + 200, _min_speed, _max_speed)
		if !speed_increase_timer.is_stopped():
			speed_increase_timer.stop()
		speed_increase_timer.start(_speed_increase_duration)
