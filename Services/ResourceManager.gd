extends Node

const loading_screen_scene_path := "res://Scenes/LoadingScreen/LoadingScreen.tscn"
const main_screen_scene_path := "res://Scenes/MainScreen/MainScreen.tscn"
const pause_screen_scene_path := "res://Scenes/PauseScreen/PauseScreen.tscn"
const settings_screen_scene_path := "res://Scenes/SettingsPanel/SettingsPanel.tscn"
const game_scene_path := "res://Scenes/Game.tscn"

const player_scene = preload("res://Scenes/Player/Player.tscn")
const player_panel_scene = preload("res://Scenes/PlayerPanel/PlayerPanel.tscn")
const bomb_scene = preload("res://Scenes/Bomb/Bomb.tscn")

const explosion_start = preload("res://Scenes/Bomb/Explosion/ExplosionStart.tscn")
const explosion_middle = preload("res://Scenes/Bomb/Explosion/ExlosionMiddle.tscn")
const explosion_end = preload("res://Scenes/Bomb/Explosion/ExplosionEnd.tscn")

const power_up_extra_bomb_texture = preload("res://Assets/ItemExtraBomb.png")
const power_up_blast_radius_texture = preload("res://Assets/ItemBlastRadius.png")
const power_up_speed_increase_texture = preload("res://Assets/ItemSpeedIncrease.png")

const player_textures = {
	"white": preload("res://Assets/PlayerWhite.png"),
	"black": preload("res://Assets/PlayerBlack.png"),
	"blue": preload("res://Assets/PlayerBlue.png"),
	"red": preload("res://Assets/PlayerRed.png")
}

const player_head_textures = {
	"white": preload("res://Assets/PlayerWhiteHead.png"),
	"black": preload("res://Assets/PlayerBlackHead.png"),
	"blue": preload("res://Assets/PlayerBlueHead.png"),
	"red": preload("res://Assets/PlayerRedHead.png")
}

const player_head_died_textures = {
	"white": preload("res://Assets/PlayerWhiteHeadDied.png"),
	"black": preload("res://Assets/PlayerBlackHead.png"),
	"blue": preload("res://Assets/PlayerBlueHead.png"),
	"red": preload("res://Assets/PlayerRedHead.png")
}

func get_player_texture(playerColor: Constants.PlayerColor) -> Texture2D:
	match playerColor:
		Constants.PlayerColor.WHITE:
			return player_textures["white"]
		Constants.PlayerColor.BLACK:
			return player_textures["black"]
		Constants.PlayerColor.BLUE:
			return player_textures["blue"]
		Constants.PlayerColor.RED:
			return player_textures["red"]
		_:
			printerr("Color {0} not found.".format([playerColor]))
			return null

func get_player_head_texture(playerColor: Constants.PlayerColor) -> Texture2D:
	match playerColor:
		Constants.PlayerColor.WHITE:
			return player_head_textures["white"]
		Constants.PlayerColor.BLACK:
			return player_head_textures["black"]
		Constants.PlayerColor.BLUE:
			return player_head_textures["blue"]
		Constants.PlayerColor.RED:
			return player_head_textures["red"]
		_:
			printerr("Color {0} not found.".format([playerColor]))
			return null

func get_player_head_died_texture(playerColor: Constants.PlayerColor) -> Texture2D:
	match playerColor:
		Constants.PlayerColor.WHITE:
			return player_head_died_textures["white"]
		Constants.PlayerColor.BLACK:
			return player_head_died_textures["black"]
		Constants.PlayerColor.BLUE:
			return player_head_died_textures["blue"]
		Constants.PlayerColor.RED:
			return player_head_died_textures["red"]
		_:
			printerr("Color {0} not found.".format([playerColor]))
			return null
