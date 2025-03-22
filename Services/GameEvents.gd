extends Node

signal exit_game_pressed()

signal game_started()
signal game_ended()

# UI
signal player_bomb_count_changed(player: Player)
signal player_died(playerColor: Constants.PlayerColor)

# Bomb
signal bomb_hit(node: Node2D)
signal bomb_expoyded(player: Player)

# Brick
signal brick_destroyed(map_position: Vector2)

# PowerUp
signal extra_bomb_power_up_picked(player: Player)
signal increase_blast_length_power_up_picked(player: Player)
signal increase_speed_power_up_picked(player: Player)
