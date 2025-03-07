extends Panel

@onready var head_sprite: Sprite2D = $PlayerHead
@onready var bomb_count_label: Label = $BombCountLabel

var player_color: Constants.PlayerColor = Constants.PlayerColor.WHITE

func initialize(color: Constants.PlayerColor) -> void:
	player_color = color

func  _init() -> void:
	GameEvents.player_bomb_count_changed.connect(_on_player_bomb_count_changed)

func  _ready() -> void:
	var texture = ResourceManager.get_player_head_texture(player_color)
	head_sprite.texture = texture
	
func _on_player_bomb_count_changed(player: Player) -> void:
	if player and player_color == player.color:
		bomb_count_label.text = str(player.bomb_count)
