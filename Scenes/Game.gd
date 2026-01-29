extends Node2D

@onready var player_panel_container: HBoxContainer = $PanelContainer/MarginContainer/HBoxContainer
@onready var player_container: Node2D = $PlayerContainer
var players = [
	{
		id = 0,
		color = Constants.PlayerColor.WHITE,
		device_id = -1,
		spawn_position = Vector2(96 + 416,96 + 120),
		is_active = false
	},
		{
		id = 1,
		color = Constants.PlayerColor.BLACK,
		device_id = 0,
		spawn_position = Vector2(96 + 416,864 + 120),
		is_active = false
	},
		{
		id = 2,
		color = Constants.PlayerColor.BLUE,
		device_id = 1,
		spawn_position = Vector2(992 + 416,96 + 120),
		is_active = false
	},
		{
		id = 3,
		color = Constants.PlayerColor.RED,
		device_id = 2,
		spawn_position = Vector2(992 + 416,864 + 120),
		is_active = false
	}
]

func _ready() -> void:
	# check device of who press start button to assign it as player1
	
	# var palyers_amount = GameSettings.get_players_amount()
	var palyers_amount = 4
	for i in range(palyers_amount):
		var player = players[i]
		if player.is_active:
			print_debug("PlayerId {0} is active.".format([player.id]))
		_add_player_panel(player.color)
		_add_player(player.color, player.device_id, player.spawn_position)
		player.is_active = true
	
	GameEvents.game_started.emit()

func _exit_tree() -> void:
	GameEvents.game_ended.emit()

func _add_player(color: Constants.PlayerColor, deviceId: int, spawn_position: Vector2) -> void:
	var player: Player = ResourceManager.player_scene.instantiate()
	player.initialize(color, deviceId)
	player_container.add_child(player)
	player.global_position = spawn_position

func _add_player_panel(color: Constants.PlayerColor) -> void:
	var player_panel = ResourceManager.player_panel_scene.instantiate()
	player_panel.initialize(color)
	player_panel_container.add_child(player_panel)
