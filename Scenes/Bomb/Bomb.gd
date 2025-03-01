extends StaticBody2D


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var bomb_sprite: Sprite2D = $Bomb
@onready var explosion_sprites: Node2D = $ExplosionSprites

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().create_timer(3).timeout.connect(_on_timeout)

func _on_timeout() -> void:
	expoyded.call_deferred()
	
func expoyded() -> void:
	animation_tree["parameters/conditions/is_exploded"] = true
	bomb_sprite.visible = false
	explosion_sprites.visible = true

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	print_debug("Bomb animation ended: ", anim_name)
	if anim_name == "explosion":
		queue_free()

func _on_animation_tree_animation_started(anim_name: StringName) -> void:
	print_debug("Bomb animation started: ", anim_name)
