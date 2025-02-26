extends Node

const player_scene = preload("res://Scenes/Player/Player.tscn")

const player_textures = {
	"white": preload("res://Assets/PlayerWhite.png"),
	"black": preload("res://Assets/PlayerBlack.png"),
	"blue": preload("res://Assets/PlayerBlue.png"),
	"red": preload("res://Assets/PlayerRed.png")
}

func get_texture(playerColor: Constants.PlayerColor) -> Texture2D:
	match playerColor:
		Constants.PlayerColor.WHITE:
			var x = load("res://Assets/PlayerWhite.png")
			return x
			#return player_textures["white"]
		Constants.PlayerColor.BLACK:
			return player_textures["black"]
		Constants.PlayerColor.BLUE:
			return player_textures["blue"]
		Constants.PlayerColor.RED:
			return player_textures["red"]
		_:
			printerr("Color {0} not found.".format([playerColor]))
			return null
