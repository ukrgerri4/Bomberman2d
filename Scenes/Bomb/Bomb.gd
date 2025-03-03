class_name Bomb
extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var bomb_sprite: Sprite2D = $Bomb
@onready var explosion_sprites: Node2D = $ExplosionSprites
@onready var explosion_area: Area2D = $ExplosionArea2D

var _is_expoyded: bool = false
var _explosion_timer: SceneTreeTimer = null
var _explosion_delay: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.bomb_hit.connect(_on_bomb_hit)
	_explosion_timer = get_tree().create_timer(_explosion_delay)
	_explosion_timer.timeout.connect(_on_timeout)
	
	print("Bomb:", name, "Animation:", animation_tree)

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
	
	animation_tree["parameters/conditions/is_exploded"] = true
	bomb_sprite.visible = false
	explosion_sprites.visible = true
	explosion_area.monitoring = true


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	#print_debug("Bomb animation ended: ", anim_name)
	if anim_name == "explosion":
		queue_free()


func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	#print_debug("Bomb animation started: ", anim_name)
	pass


func _on_explosion_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		GameEvents.player_hit.emit(body)
	elif body is Bomb:
		GameEvents.bomb_hit.emit(body)
	#elif body is Wall:
