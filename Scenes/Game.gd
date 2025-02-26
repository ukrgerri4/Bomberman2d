extends Node2D


func _ready() -> void:
	var player1: Player = ResourceManager.player_scene.instantiate()
	player1.color = Constants.PlayerColor.WHITE
	
	var player2: Player = ResourceManager.player_scene.instantiate()
	player2.color = Constants.PlayerColor.BLACK
	
	var player3: Player = ResourceManager.player_scene.instantiate()
	player3.color = Constants.PlayerColor.BLUE
	
	var player4: Player = ResourceManager.player_scene.instantiate()
	player4.color = Constants.PlayerColor.RED
	
	add_child(player1)
	add_child(player2)
	add_child(player3)
	add_child(player4)
	
	player1.global_position = Vector2(120,56)
	player2.global_position = Vector2(120,120)
	player3.global_position = Vector2(248,56)
	player4.global_position = Vector2(248,120)
