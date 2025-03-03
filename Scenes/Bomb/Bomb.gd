class_name Bomb
extends Node2D

@onready var bomb_sprite: Sprite2D = $BombSrpite2D
@onready var bomb_area: Area2D = $BombArea2D
@onready var bomb_collision_shape: CollisionShape2D = $BombCollisionShape2D

@onready var explosion_area: Area2D = $ExplosionArea2D
@onready var explosion_sprites: Node2D = $ExplosionSprites

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

var _is_expoyded: bool = false
var _explosion_timer: SceneTreeTimer = null
var _explosion_delay: float = 3.0

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

func _on_bomb_hit(bomb: Bomb) -> void:
	if bomb == self:
		_expoyded.call_deferred()

func _expoyded() -> void:
	if _is_expoyded:
		return
	
	_is_expoyded = true
	
	if _explosion_timer and _explosion_timer.timeout.is_connected(_on_timeout):
		_explosion_timer.timeout.disconnect(_on_timeout)
		#print_debug("Timer disconnected")
	
	_update_explosion_animation()
	animation_tree["parameters/conditions/is_exploded"] = true
	bomb_sprite.visible = false
	explosion_sprites.visible = true
	explosion_area.monitoring = true

func _update_explosion_animation() -> void:
	var animation_name = "explosion"
	#if animation_player.has_animation(animation_name):
		#animation_player.remove_animation(animation_name)
	var animation = animation_player.get_animation(animation_name)
	var parts = get_node("ExplosionSprites").get_children()
	for part in parts:
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_index, str(part.get_path()) + ":frame")
		for i in range(8):
			animation.track_insert_key(track_index, 0.25 * i, i)
	

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	#print_debug("Bomb animation ended: ", anim_name)
	if anim_name == "explosion":
		queue_free()

func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	#print_debug("Bomb animation started: ", anim_name)
	pass

func _on_explosion_area_2d_body_entered(body: Node2D) -> void:
	#print_debug("Explosion area body entered: ", body)
	if body is Player:
		GameEvents.player_hit.emit(body)
	elif body is Bomb:
		GameEvents.bomb_hit.emit(body)
	#elif body is Wall:

func _on_bomb_area_2d_body_exited(body: Node2D) -> void:
	#print_debug("Explosion area body entered: ", body)
	_enable_bomb_collision.call_deferred() 

func _enable_bomb_collision() -> void:
	bomb_collision_shape.disabled = false
