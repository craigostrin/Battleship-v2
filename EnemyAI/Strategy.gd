class_name Strategy
extends Node

var grid: Grid
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()


func get_random_guess(unguessed_indexes: Array) -> int:
	var random_index := _get_random_index(unguessed_indexes)
	var random_guess = unguessed_indexes[random_index]
	
	return random_guess


func calculate_next_guesses(next_guesses: Array, last_hit: int, last_last_hit: int) -> Array:
	return next_guesses


func _get_valid_adjacents(index: int) -> Array:
	var valids := []
	var adjacents := grid.get_adjacents(index)
	
	for i in adjacents:
		if grid.is_valid_target(i):
			valids.append(i)
	
	return valids


func _get_remaining_hits() -> Array:
	var remaining_hits := []
	
	var i := 0
	for cell in grid.cells:
		if cell == grid.States.HIT:
			remaining_hits.append(i)
		i += 1
	
	return remaining_hits


func _get_random_index(array: Array) -> int:
	# I found randi() % max created a more random distribution than randi_range(), which
	# had ships bunching up on the edges a lot
	var _max = array.size() - 1
	return rng.randi() % _max
