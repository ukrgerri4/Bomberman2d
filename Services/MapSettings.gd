extends Node

const MAP_WIDTH: int = 17
const MAP_HEIGHT: int = 15
const BLOCK_SIZE: int = 64
const HALF_BLOCK_SIZE: float = BLOCK_SIZE / 2.0
const OFFSET_TOP: float = 1080 - (MAP_HEIGHT * BLOCK_SIZE)
const OFFSET_LEFT: float = (1920 - (MAP_WIDTH * BLOCK_SIZE)) / 2.0
