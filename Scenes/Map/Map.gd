class_name Map
extends Node2D

const ground_scene = preload("res://Scenes/Ground/Ground.tscn")
const ground_shadow_scene = preload("res://Scenes/GroundShadow/GroundShadow.tscn")
const wall_scene = preload("res://Scenes/Wall/Wall.tscn")
const brick_scene = preload("res://Scenes/Brick/Brick.tscn")
const power_up_scene = preload("res://Scenes/PowerUp/PowerUp.tscn")

func  _init() -> void:
	_generate_level()

func _generate_level() -> void:
	for w in range(MapSettings.MAP_WIDTH):
		MapSettings.cells.append([])
		for h in range(MapSettings.MAP_HEIGHT):
			MapSettings.cells[w].append([])
			if _is_wall(w, h):
				var wall = wall_scene.instantiate()
				_add_tocells(wall, w, h)
				MapSettings.cells[w][h].append(Constants.MapCellType.WALL)
			else:
				if _is_ground(w, h):
					var ground = ground_scene.instantiate()
					_add_tocells(ground, w, h)
					MapSettings.cells[w][h].append(Constants.MapCellType.GROUND)
				elif _is_ground_shadow(w, h):
					var ground_shadow = ground_shadow_scene.instantiate()
					_add_tocells(ground_shadow, w, h)
					MapSettings.cells[w][h].append(Constants.MapCellType.GROUND)
					
				if w > 4 and w < (MapSettings.MAP_WIDTH - 4) and h > 4 and h < (MapSettings.MAP_HEIGHT - 4):
					var brick = brick_scene.instantiate()
					_add_tocells(brick, w, h)
					MapSettings.cells[w][h].append(Constants.MapCellType.BRICK)
					
				# place powerups
	#print(MapSettings.cells)

func _is_wall(width: int, height: int) -> bool:
	return width == 0 or width == (MapSettings.MAP_WIDTH - 1) or \
		height == 0 or height == (MapSettings.MAP_HEIGHT - 1) or \
		(width % 2 == 0 and height % 2 == 0)

func _is_ground(width: int, height: int) -> bool:
	return width % 2 == 1 and height != 1

func _is_ground_shadow(_width: int, height: int) -> bool:
	return height % 2 == 1 

func _add_tocells(node: Node2D, width: float, height: float) -> void:
	self.add_child(node)
	node.global_position = Vector2(
		MapSettings.OFFSET_LEFT + width * MapSettings.BLOCK_SIZE + MapSettings.HALF_BLOCK_SIZE,
		MapSettings.OFFSET_TOP + height * MapSettings.BLOCK_SIZE + MapSettings.HALF_BLOCK_SIZE
	)
