class_name Bomb
extends Node2D

const EXPLOSION_ANIMATION_NAME: String = "explosion"

@onready var bomb_animated_sprite: AnimatedSprite2D = $BombAnimatedSrpite2D
@onready var bomb_area: Area2D = $BombArea2D
@onready var bomb_collision_shape: CollisionShape2D = $BombCollisionShape2D

@onready var explosion_area: Area2D = $ExplosionArea2D
@onready var up_explosion_area: CollisionShape2D = $ExplosionArea2D/UpCollisionShape
@onready var down_explosion_area: CollisionShape2D = $ExplosionArea2D/DownCollisionShape
@onready var left_explosion_area: CollisionShape2D = $ExplosionArea2D/LeftCollisionShape
@onready var right_explosion_area: CollisionShape2D = $ExplosionArea2D/RightCollisionShape

@onready var explosion_sprites: Node2D = $ExplosionSprites

@onready var animation_player: AnimationPlayer

var _is_exployded: bool = false
var _explosion_dict: Dictionary[Vector2, Array] = {
	Vector2.UP: [],
	Vector2.DOWN: [],
	Vector2.LEFT: [],
	Vector2.RIGHT: []
}
var _explosion_timer: SceneTreeTimer = null
var _explosion_delay: float = 3.0
var _explosion_length: int = 2

func _ready() -> void:
	bomb_collision_shape.disabled = true
	GameEvents.bomb_hit.connect(_on_bomb_hit)
	_explosion_timer = get_tree().create_timer(_explosion_delay)
	_explosion_timer.timeout.connect(_on_timeout)

func _exit_tree():
	if GameEvents.bomb_hit.is_connected(_on_bomb_hit):
		GameEvents.bomb_hit.disconnect(_on_bomb_hit)
	if _explosion_timer and _explosion_timer.timeout.is_connected(_on_timeout):
		_explosion_timer.timeout.disconnect(_on_timeout)

func _on_timeout() -> void:
	_expoyded.call_deferred()

func _on_bomb_hit(node: Node2D) -> void:
	if node is Bomb and node == self:
		_expoyded.call_deferred()

func _expoyded() -> void:
	if _is_exployded:
		return
	
	_is_exployded = true
	
	if _explosion_timer and _explosion_timer.timeout.is_connected(_on_timeout):
		_explosion_timer.timeout.disconnect(_on_timeout)
	
	_update_explosion_sprites()
	_update_explosion_area()
	_update_explosion_animation()

func _update_explosion_sprites() -> void:
	var start = ResourceManager.explosion_start.instantiate()
	explosion_sprites.add_child(start)
	start.global_position = global_position
	
	_update_explosion_beam(Vector2.UP)
	_update_explosion_beam(Vector2.DOWN)
	_update_explosion_beam(Vector2.LEFT)
	_update_explosion_beam(Vector2.RIGHT)

func _update_explosion_beam(direction: Vector2) -> void:
	_explosion_dict[direction].append(global_position)
	for i in range(_explosion_length):
		var beam_number = i + 1
		var beam_position = _get_beam_position(direction, beam_number)
		var is_collide = true
		var is_collide_with_brick = false
		var collider = _check_collision(beam_position)
		_check_collision2(beam_position)
		
		if collider == null:
			is_collide = false
		elif collider.is_in_group("bricks"):
			is_collide = false
			is_collide_with_brick = true
		
		if not is_collide:
			var top_beam: Sprite2D
			if beam_number == _explosion_length:
				top_beam = ResourceManager.explosion_end.instantiate()
			else:
				top_beam = ResourceManager.explosion_middle.instantiate()
			explosion_sprites.add_child(top_beam)
			top_beam.rotation_degrees = _get_beam_rotation(direction)
			top_beam.global_position = beam_position
			_explosion_dict[direction].append(beam_position)
			
		if is_collide or is_collide_with_brick:
			return

func _check_collision(point: Vector2) -> Node2D:
	var space_state = get_world_2d().direct_space_state
	var query =  PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = (1 << 2) | (1 << 3) # wall and brick
	var result = space_state.intersect_point(query, 1)
	if result.size() == 1:
		return result[0].collider;
	return null

func _check_collision2(point: Vector2) -> Constants.MapCellType:
	var x = ceil((point.x - MapSettings.OFFSET_LEFT) / MapSettings.BLOCK_SIZE) - 1
	var y = ceil((point.y - MapSettings.OFFSET_TOP) / MapSettings.BLOCK_SIZE) - 1
	var max = Array(MapSettings.cells[x][y]).max()
	#print("{0}, {1}, {2}, {3}".format([x, y, max, point]))
	return max

func _update_explosion_area() -> void:
	var up_values = _explosion_dict[Vector2.UP].map(func(v: Vector2): return v.y)
	_update_area(up_values, up_explosion_area)
	var down_values = _explosion_dict[Vector2.DOWN].map(func(v: Vector2): return v.y)
	_update_area(down_values, down_explosion_area)
	var left_values = _explosion_dict[Vector2.LEFT].map(func(v: Vector2): return v.x)
	_update_area(left_values, left_explosion_area)
	var right_values = _explosion_dict[Vector2.RIGHT].map(func(v: Vector2): return v.x)
	_update_area(right_values, right_explosion_area)


func _update_area(values: Array, collision_shape: CollisionShape2D) -> void:
	if values.size() <= 1:
		collision_shape.disabled = true
	else:
		(collision_shape.shape as CapsuleShape2D).height = (abs(values.max()) - abs(values.min()))
	

func _get_beam_position(direction: Vector2, beam_number: int) -> Vector2:
	match direction:
		Vector2.UP:
			return Vector2(global_position.x, global_position.y - MapSettings.BLOCK_SIZE * beam_number)
		Vector2.DOWN:
			return Vector2(global_position.x, global_position.y + MapSettings.BLOCK_SIZE * beam_number)
		Vector2.LEFT:
			return Vector2(global_position.x - MapSettings.BLOCK_SIZE * beam_number, global_position.y)
		Vector2.RIGHT:
			return Vector2(global_position.x + MapSettings.BLOCK_SIZE * beam_number, global_position.y)
		_:
			return Vector2.ZERO

func _get_beam_rotation(direction: Vector2) -> int:
	match direction:
		Vector2.UP:
			return -90
		Vector2.DOWN:
			return 90
		Vector2.LEFT: 
			return 180
		Vector2.RIGHT:
			return 0
		_:
			return 0

func _update_explosion_animation() -> void:
	if animation_player:
		animation_player.queue_free()
	animation_player = AnimationPlayer.new()
	add_child(animation_player)
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	var animation_library = AnimationLibrary.new()
	animation_player.add_animation_library("", animation_library)
	var animation = Animation.new()	
	var parts = explosion_sprites.get_children()
	for part in parts:
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, str(part.get_path()) + ":frame")
		for i in range(8):
			animation.track_insert_key(track_index, 0.25 * i, i)
	animation_library.add_animation(EXPLOSION_ANIMATION_NAME, animation)
	bomb_collision_shape.disabled = true
	bomb_animated_sprite.visible = false
	bomb_animated_sprite.stop()
	explosion_sprites.visible = true
	explosion_area.monitoring = true
	animation_player.play(EXPLOSION_ANIMATION_NAME)

func _on_explosion_area_2d_body_entered(body: Node2D) -> void:
	#print_debug("Explosion area body entered: ", body)
	GameEvents.bomb_hit.emit(body)

func _on_bomb_area_2d_body_exited(_body: Node2D) -> void:
	#print_debug("Explosion area body entered: ", body)
	_enable_bomb_collision.call_deferred() 

func _enable_bomb_collision() -> void:
	bomb_collision_shape.disabled = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explosion":
		queue_free()
