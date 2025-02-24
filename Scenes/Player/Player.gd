extends CharacterBody2D


const SPEED = 50.0

var is_dead: bool = false
var direction: Vector2 = Vector2.ZERO

@onready var animation_tree: AnimationTree = $AnimationTree

func _process(delta: float) -> void:
	update_animation()

func _physics_process(_delta: float) -> void:
	var x: float = Input.get_axis("ui_left", "ui_right")
	var y: float = Input.get_axis("ui_up", "ui_down")
	
	if (abs(x) == abs(y) && x != 0 && y != 0):
		x = x if abs(direction.x) > abs(direction.y) else 0.0
		y = y if abs(direction.y) > abs(direction.x) else 0.0
	
	direction = Vector2(
		x if abs(x) > abs(y) else 0.0,
		y if abs(y) > abs(x) else 0.0
	).normalized()
	
	if not direction.is_zero_approx():
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func update_animation() -> void:
	if (is_dead):
		animation_tree["parameters/conditions/is_dead"] = is_dead
	
	animation_tree["parameters/walk/blend_position"] = direction

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dead":
		print_debug("Animation ended: ", anim_name)
		#update_score()
		queue_free()
