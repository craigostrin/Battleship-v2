class_name EnemyAI
extends Node

# TODO: I'd like to experiment with the Strategy pattern with two attack guessing algorithms:
# 			One basic algorithm with totally random guessing
# 			One complex algorithm with checkerboard guessing (see: https://www.thesprucecrafts.com/how-to-win-at-battleship-411068)

# Easy/Med/Hard - will be child nodes
# Easy: Basic AI, guesses completely randomly
# Medium: Basic AI but kills ships after finding them
# Hard: Checkerboard guesses
## For Hard (maybe Med too?), AI will cheat a bit --> after sinking a ship, scan the Grid for
## ships that've been hit but not sunk to find next guesses
onready var strategy: Strategy = $MediumStrategy

var next_guesses := []
var unguessed_indexes := []
var last_hit := -1
var last_last_hit := -1
var think_time := 0.5

var rng := RandomNumberGenerator.new()
var grid := Grid.new()
var opponent_board: Board
var my_board: Board

onready var _timer: Timer = $Timer


func init(_my_board: Board, _opponent_board: Board) -> void:
	my_board = _my_board
	opponent_board = _opponent_board


func _ready() -> void:
	rng.randomize()
	my_board.connect("ship_not_placed", self, "_on_ship_not_placed")
	opponent_board.connect("target_not_confirmed", self, "_try_attack")
	opponent_board.connect("target_confirmed", self, "_on_target_confirmed")
	opponent_board.connect("hit", self, "_on_ship_hit")
	opponent_board.connect("ship_sunk", self, "_on_ship_sunk")
	initialize_unguessed()
	strategy.grid = opponent_board.grid


# DEBUG (duh)
func debug_draw() -> void:
	if next_guesses.size() > 0:
		for index in next_guesses:
			var pos: Vector2 = opponent_board.grid.calculate_board_position(index)
			var rect = Rect2(pos, grid.cell_size)
			opponent_board.rects.append(rect)
	else:
		opponent_board.rects.clear()


func initialize_unguessed() -> void:
	for row in grid.rows:
		for column in grid.columns:
			var index = column + row * grid.columns
			unguessed_indexes.append(index)


func start_turn(number_of_attacks: int) -> void:
	for i in number_of_attacks:
		_try_attack()
		yield(opponent_board, "target_confirmed")


func _try_attack() -> void:
	var unguessed_index: int
	
	if next_guesses.size() == 0 and last_hit >= 0:
		next_guesses = strategy.calculate_next_guesses(next_guesses, last_hit, last_last_hit)
	
	_timer.start(think_time)
	yield(_timer, "timeout")
	
	# Default: Pick a random, unguessed index
	var random_index = _get_random_index(unguessed_indexes)
	unguessed_index = unguessed_indexes[random_index]
	
	if next_guesses.size() > 0:
		var strategic_guess = next_guesses[0]
		if strategic_guess in unguessed_indexes:
			unguessed_index = strategic_guess
		next_guesses.remove(0)
	
	opponent_board.target_cell(unguessed_index)


func _on_target_confirmed(index: int) -> void:
	unguessed_indexes.erase(index)
	#print("enemy ai attacked " + str(index))


func _on_ship_hit(index: int) -> void:
	last_last_hit = last_hit
	last_hit = index
	next_guesses = strategy.calculate_next_guesses(next_guesses, last_hit, last_last_hit)


func _on_ship_sunk() -> void:
	last_last_hit = -1
	last_hit = -1
	next_guesses.clear()


############################################
############## SHIP PLACEMENT ##############
############################################
func start_ship_placement() -> void:
	for length in my_board.ship_lengths:
		var ship = Ship.new(length)
		_try_place_ship(ship)


func _try_place_ship(ship: Ship) -> void:
	# GET RANDOM SHIP PARAMETERS
	var index = _get_random_index(my_board.grid.cells)
	var is_vertical = _get_random_bool()
	index = my_board.grid.clamp_ship_placement(index, ship.length, is_vertical)
	ship.is_vertical = is_vertical
	
	# CHECK IF ANY SHIPS ARE ADJACENT TO PROPOSED POSITION
	var no_ships_adjacent := true
	var ship_index_array: PoolIntArray = my_board.grid.get_ship_index_array(index, ship.length, is_vertical)
	
	for i in ship_index_array:
		var adjacents = my_board.grid.get_adjacents(i)
		var adjacent_cell_states = _get_cell_states(adjacents)
		if my_board.grid.States.SHIP in adjacent_cell_states:
			no_ships_adjacent = false
	
	if no_ships_adjacent:
		my_board.place_ship(ship, index)
	else:
		_try_place_ship(ship)


func _get_cell_states(index_array: PoolIntArray) -> PoolIntArray:
	var cell_array: PoolIntArray
	
	for index in index_array:
		var cell_state = my_board.grid.cells[index]
		cell_array.append(cell_state)
	
	return cell_array


func _on_ship_not_placed(ship: Ship) -> void:
	_try_place_ship(ship)


func _get_random_index(array: Array) -> int:
	# I found randi() % max created a more random distribution than randi_range(), which
	# had ships bunching up on the edges a lot
	var _max = array.size() - 1
	return rng.randi() % _max


func _get_random_bool() -> bool:
	var boolean = true
	if rng.randi() % 2:
		boolean = false
	return boolean
