extends Node

# UI
signal player_bomb_count_changed(player: Player)

# Bomb
signal bomb_hit(node: Node2D)
signal bomb_expoyded(player: Player)

# PowerUp
signal extra_bomb_power_up_picked(player: Player)
signal increase_blast_length_power_up_picked(player: Player)
signal increase_speed_power_up_picked(player: Player)
