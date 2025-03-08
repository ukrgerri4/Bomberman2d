class_name Map
extends Node2D

const BRICKS_NUMBER: int = 80
# should be divided by 3, to create 3 type of powerups
const POWER_UPS_NUMBER: int = 12

const ground_scene = preload("res://Scenes/Ground/Ground.tscn")
const ground_shadow_scene = preload("res://Scenes/GroundShadow/GroundShadow.tscn")
const wall_scene = preload("res://Scenes/Wall/Wall.tscn")
const brick_scene = preload("res://Scenes/Brick/Brick.tscn")
const power_up_scene = preload("res://Scenes/PowerUp/PowerUp.tscn")

func  _init() -> void:
	_generate_level()

func _generate_level() -> void:
	var random_cells: Array[Vector2] = []
	
	for w in range(MapSettings.MAP_WIDTH):
		MapSettings.cells.append([])
		for h in range(MapSettings.MAP_HEIGHT):
			MapSettings.cells[w].append([])
			if _is_wall(w, h):
				var wall = wall_scene.instantiate()
				_add_to_cells(wall, w, h)
				MapSettings.cells[w][h].append(Constants.MapCellType.WALL)
			else:
				if _is_ground(w, h):
					var ground = ground_scene.instantiate()
					_add_to_cells(ground, w, h)
					MapSettings.cells[w][h].append(Constants.MapCellType.GROUND)
				elif _is_ground_shadow(w, h):
					var ground_shadow = ground_shadow_scene.instantiate()
					_add_to_cells(ground_shadow, w, h)
					MapSettings.cells[w][h].append(Constants.MapCellType.GROUND)

				if _is_player_spawn_positions(w, h):
					continue
				else:
					random_cells.append(Vector2(w, h))
	
	# Generate random bricks
	var brick_indexes: Array[int] = []
	var brick_divider: int = random_cells.size()
	while brick_indexes.size() < BRICKS_NUMBER:
		var rand_index = randi() % brick_divider
		if rand_index not in brick_indexes:
			brick_indexes.append(rand_index)
	
	for i in brick_indexes:
		var cell = random_cells[i]
		var brick = brick_scene.instantiate()
		_add_to_cells(brick, cell.x, cell.y)
		MapSettings.cells[cell.x][cell.y].append(Constants.MapCellType.BRICK)
	
	# Generate random power ups
	var power_up_indexes: Array[int] = []
	var power_up_divider: int = brick_indexes.size()
	while power_up_indexes.size() < POWER_UPS_NUMBER:
		var rand_index = randi() % power_up_divider
		if rand_index not in power_up_indexes:
			power_up_indexes.append(rand_index)
	
	var power_up_counter: int = 0
	for i in power_up_indexes:
		var random_brick_index = brick_indexes[i]
		var cell = random_cells[random_brick_index]
		var power_up: Node2D
		
		if power_up_counter < POWER_UPS_NUMBER / 3:
			power_up = power_up_scene.instantiate()
			power_up.type = Constants.PowerUpType.SPEED_INCREASE
		if power_up_counter >= POWER_UPS_NUMBER / 3 and power_up_counter < POWER_UPS_NUMBER / 3 * 2:
			power_up = power_up_scene.instantiate()
			power_up.type = Constants.PowerUpType.EXTRA_BOMB
		if power_up_counter >= POWER_UPS_NUMBER / 3 * 2 and power_up_counter < POWER_UPS_NUMBER:
			power_up = power_up_scene.instantiate()
			power_up.type = Constants.PowerUpType.BLAST_INCREASE
		
		_add_to_cells(power_up, cell.x, cell.y)
		MapSettings.cells[cell.x][cell.y].append(Constants.MapCellType.POWER_UP)
		power_up_counter += 1

func _is_wall(width: int, height: int) -> bool:
	return width == 0 or width == (MapSettings.MAP_WIDTH - 1) or \
		height == 0 or height == (MapSettings.MAP_HEIGHT - 1) or \
		(width % 2 == 0 and height % 2 == 0)

func _is_ground(width: int, height: int) -> bool:
	return width % 2 == 1 and height != 1

func _is_ground_shadow(_width: int, height: int) -> bool:
	return height % 2 == 1 

func _add_to_cells(node: Node2D, width: float, height: float) -> void:
	self.add_child(node)
	node.global_position = Vector2(
		MapSettings.OFFSET_LEFT + width * MapSettings.BLOCK_SIZE + MapSettings.HALF_BLOCK_SIZE,
		MapSettings.OFFSET_TOP + height * MapSettings.BLOCK_SIZE + MapSettings.HALF_BLOCK_SIZE
	)

func _is_player_spawn_positions(width: int, height: int) -> bool:
	# Players spawn positions and 2 empty cells near
	return (width == 1 and height == 1) or \
		(width == 2 and height == 1) or \
		(width == 1 and height == 2) or \
		(width == 1 and height == 13) or \
		(width == 1 and height == 12) or \
		(width == 2 and height == 13) or \
		(width == 15 and height == 1) or \
		(width == 14 and height == 1) or \
		(width == 15 and height == 2) or \
		(width == 15 and height == 13) or \
		(width == 14 and height == 13) or \
		(width == 15 and height == 12)
