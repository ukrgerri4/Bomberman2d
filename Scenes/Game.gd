extends Node2D


@onready var player_container: Node2D = $PlayerContainer
var players = [
	{
		id = 0,
		color = Constants.PlayerColor.WHITE,
		device_id = -1,
		spawn_position = Vector2(24,24),
		is_active = false
	},
		{
		id = 1,
		color = Constants.PlayerColor.BLACK,
		device_id = 0,
		spawn_position = Vector2(24,184),
		is_active = false
	},
		{
		id = 2,
		color = Constants.PlayerColor.BLUE,
		device_id = 1,
		spawn_position = Vector2(344,24),
		is_active = false
	},
		{
		id = 3,
		color = Constants.PlayerColor.RED,
		device_id = 2,
		spawn_position = Vector2(344,184),
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
		add_player(player.color, player.device_id, player.spawn_position)
		player.is_active = true
	#add_player(Constants.PlayerColor.WHITE, -1, Vector2(120,56))
	#add_player(Constants.PlayerColor.BLACK, 0, Vector2(120,120))
	#add_player(Constants.PlayerColor.BLUE, 1, Vector2(248,56))
	#add_player(Constants.PlayerColor.RED, 2, Vector2(248,120))

func add_player(color: Constants.PlayerColor, deviceId: int, spawn_position: Vector2) -> void:
	var player: Player = ResourceManager.player_scene.instantiate()
	player.initialize(color, deviceId)
	player_container.add_child(player)
	player.global_position = spawn_position
