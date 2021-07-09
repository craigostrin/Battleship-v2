class_name EnemyAI
extends Node

var rng := RandomNumberGenerator.new()
# DEBUG Make sure to figure out what to do with this.. maybe all placement methods use my_board.grid?
var grid := Grid.new()
onready var player_board: Board = $"../Boards/PlayerBoard"
onready var my_board: Board = $"../Boards/EnemyBoard"


func _ready() -> void:
	rng.randomize()
	my_board.connect("ship_not_placed", self, "_on_ship_not_placed")


func start_ship_placement() -> void:
	for length in my_board.ship_lengths:
		var ship = Ship.new(length)
		_try_place_ship(ship)


func _try_place_ship(ship: Ship) -> void:
	# GET RANDOM SHIP PARAMETERS
	var index = _get_random_index()
	var is_vertical = _get_random_bool()
	index = grid.clamp_ship_placement(index, ship.length, is_vertical)
	ship.is_vertical = is_vertical
	
	# CHECK IF ANY SHIPS ARE ADJACENT TO PROPOSED POSITION
	var no_ships_adjacent := true
	var ship_index_array := grid.get_ship_index_array(index, ship.length, is_vertical)
	
	for i in ship_index_array:
		var adjacents = grid.get_adjacents(i)
		var adjacent_cell_states = _get_cell_states(adjacents)
		if grid.States.SHIP in adjacent_cell_states:
			no_ships_adjacent = false
	
	if no_ships_adjacent:
		my_board.place_ship(ship, index)
	else:
		print(ship.name + " was too close to another ship")
		_try_place_ship(ship)


func _get_cell_states(index_array: PoolIntArray) -> PoolIntArray:
	var cell_array: PoolIntArray
	
	for index in index_array:
		var cell_state = my_board.grid.cells[index]
		cell_array.append(cell_state)
	
	return cell_array


func _on_ship_not_placed(ship: Ship) -> void:
	_try_place_ship(ship)


func _get_random_index() -> int:
	var _max = grid.columns * grid.rows #- 1
	return rng.randi() % _max
	#return rng.randi_range(0, _max)


func _get_random_bool() -> bool:
	var boolean = true
	if rng.randi() % 2:
		boolean = false
	return boolean
