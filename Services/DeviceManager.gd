extends Node


var connected_joypads = [-1]

func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	if connected:
		if device_id not in connected_joypads:
			connected_joypads.append(device_id)
			#assign_joypad(device_id)
	else:
		if device_id in connected_joypads:
			connected_joypads.erase(device_id)
			#unassign_joypad(device_id)
			
	print_debug("DeviceId: {0}, {1}. Using devices: [{2}].".format([device_id, "connected" if connected else "disconnected", ", ".join(connected_joypads)]))
