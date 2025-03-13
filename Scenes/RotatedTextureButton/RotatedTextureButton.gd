extends TextureButton

const TWEEN_TIME: float = 1.5
const DEGREES_Y: float = 10.0
const DEGREES_X: float = 5.0
const TWEEN_TRANS: Tween.TransitionType = Tween.TRANS_QUAD

var _tween: Tween
var _is_mouse_inside_button: bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)

func _start_animation():
	# Scale up button
	if _tween:
		_tween.kill()
	_tween = create_tween()
	# initial value should be 0.1 for this parameter
	_tween.tween_property(material, "shader_parameter/inset", 0.0, 0.2).set_trans(Tween.TRANS_LINEAR)
	await _tween.finished
	
	# Start rotation loop
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_loops()
	
	_tween.tween_property(material, "shader_parameter/y_rot", DEGREES_Y, TWEEN_TIME).set_trans(TWEEN_TRANS).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(material, "shader_parameter/x_rot", DEGREES_X, TWEEN_TIME).set_trans(TWEEN_TRANS).set_ease(Tween.EASE_OUT)
	
	_tween.tween_property(material, "shader_parameter/y_rot", 0.0, TWEEN_TIME).set_trans(TWEEN_TRANS).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(material, "shader_parameter/x_rot", 0.0, TWEEN_TIME).set_trans(TWEEN_TRANS).set_ease(Tween.EASE_IN)
	
	_tween.tween_property(material, "shader_parameter/y_rot", DEGREES_Y * -1, TWEEN_TIME).set_trans(TWEEN_TRANS).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(material, "shader_parameter/x_rot", DEGREES_X * -1, TWEEN_TIME).set_trans(TWEEN_TRANS).set_ease(Tween.EASE_OUT)
	
	_tween.tween_property(material, "shader_parameter/y_rot", 0.0, TWEEN_TIME).set_trans(TWEEN_TRANS).set_ease(Tween.EASE_IN)
	_tween.parallel().tween_property(material, "shader_parameter/x_rot", 0.0, TWEEN_TIME).set_trans(TWEEN_TRANS).set_ease(Tween.EASE_IN)

func _end_animation() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(material, "shader_parameter/inset", 0.1, 0.1).set_trans(Tween.TRANS_LINEAR)
	_tween.parallel().tween_property(material, "shader_parameter/x_rot", 0, 0.1).set_trans(Tween.TRANS_LINEAR)
	_tween.parallel().tween_property(material, "shader_parameter/y_rot", 0, 0.1).set_trans(Tween.TRANS_LINEAR)

func _on_mouse_entered() -> void:
	_is_mouse_inside_button = true
	_start_animation()

func _on_mouse_exited() -> void:
	_is_mouse_inside_button = false
	_end_animation()

func _on_pressed() -> void:
	print("Button pressed")
	# TODO: implement

func _on_button_down() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(material, "shader_parameter/inset", 0.2, 0.1).set_trans(Tween.TRANS_LINEAR)
	_tween.parallel().tween_property(material, "shader_parameter/x_rot", 0, 0.1).set_trans(Tween.TRANS_LINEAR)
	_tween.parallel().tween_property(material, "shader_parameter/y_rot", 0, 0.1).set_trans(Tween.TRANS_LINEAR)

func _on_button_up() -> void:
	if _is_mouse_inside_button:
		_start_animation()
