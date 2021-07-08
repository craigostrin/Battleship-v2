class_name EnemyAI
extends Node

var rng := RandomNumberGenerator.new()
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
	var index = _get_random_index()
	var is_vertical = _get_random_bool()
	index = grid.clamp_ship_placement(index, ship.length, is_vertical)
	
	ship.is_vertical = is_vertical
	
	my_board.place_ship(ship, index)


func _get_adjacent_cells(index_array: PoolIntArray) -> PoolIntArray:
	var cell_array: PoolIntArray
	
	for index in index_array:
		var cell_state = grid.cells[index]
		cell_array.append(cell_state)
	
	return cell_array


func _on_ship_not_placed(ship: Ship) -> void:
	_try_place_ship(ship)


func _get_random_index() -> int:
	var _max = grid.columns * grid.rows - 1
	return rng.randi_range(0, _max)


func _get_random_bool() -> bool:
	var boolean = true
	if rng.randi() % 2:
		boolean = false
	return boolean
