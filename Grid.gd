class_name Grid
extends Resource

############ GRID #############
# 00 01 02 03 04 05 06 07 08 09
# 10 11 12 13 14 15 16 17 18 19
# 20 21 22 23 24 25 26 27 28 29
# 30 31 32 33 34 35 36 37 38 39
# 40 41 42 43 44 45 46 47 48 49
# 50 51 52 53 54 55 56 57 58 59
# 60 61 62 63 64 65 66 67 68 69
# 70 71 72 73 74 75 76 77 78 79
# 80 81 82 83 84 85 86 87 88 89
# 90 91 92 93 94 95 96 97 98 99
###############################

# 1D array or 2D vector dictionary?
# leaning toward the former, but I feel like I need a slight break from this
# project to clear my mind and come back fresh

var rows := 10
var columns := 10
var cell_size := Vector2(32, 32)
var _half_cell_size := cell_size / 2

var cells := []

enum States { EMPTY, SHIP, MISS, HIT }
var Directions = { "LEFT" : -1, "RIGHT" : 1, "UP" : -columns, "DOWN" : columns }


func initialize_grid() -> void:
	for row in rows:
		for column in columns:
			cells.append(States.EMPTY)


func calculate_board_position(index: int) -> Vector2:
	var board_position = Vector2()
	board_position.x = get_column(index)
	board_position.y = get_row(index)
	
	board_position = board_position * cell_size + _half_cell_size
	
	return board_position


func calculate_index_from_board_position(global_position: Vector2, board_offset: Vector2) -> int:
	var index: int
	var board_position := global_position - board_offset
	var vector_index := (board_position / cell_size).floor()
	
	index = vector_index.x + (vector_index.y * columns)
	
	return index


func clamp_ship_placement(index: int, size: int, is_vertical: bool) -> int:
	var out = index
	var column = get_column(out)
	var row = get_row(out)
	
	if not is_vertical:
		if column > (columns - size):
			var nearest_ten = ( row + 1 ) * columns
			out = (nearest_ten - size)
	else:
		if row > (rows - size):
			out = (rows - size) * columns + column
	
	return out


func is_cell_empty(index: int) -> bool:
	return true if cells[index] == States.EMPTY else false


func get_adjacents(index: int) -> PoolIntArray:
	var adjacents: PoolIntArray = []
	
	for key in Directions:
		if get_column(index) == columns - 1 and key == "RIGHT":
			continue
		
		if get_column(index) == 0 and key == "LEFT":
			continue
		
		var direction = Directions.get(key)
		var adjacent = index + direction
		
		if is_within_bounds(adjacent):
			adjacents.append(adjacent)
	
	return adjacents


func is_within_bounds(index: int) -> bool:
	return index >= 0 and index <= (rows * columns - 1)


func clamp(index: int) -> int:
	var out := index
	
	out = clamp(out, 0, rows * columns - 1)
	
	return out


func get_column(index: int) -> int:
	return index % columns


func get_row(index: int) -> int:
	return int(index / columns)


# Returns [ x, y ] or [ column, row ]
func get_column_row_array(index: int) -> PoolIntArray:
	var array: PoolIntArray = []
	
	array.append(get_column(index))
	array.append(get_row(index))
	
	return array
