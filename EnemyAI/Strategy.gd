class_name Strategy
extends Node

var grid: Grid


func calculate_next_guesses(next_guesses: Array, last_hit: int, last_last_hit: int) -> Array:
	return next_guesses


func get_valid_adjacents(index: int) -> Array:
	var valids := []
	var adjacents := grid.get_adjacents(index)
	
	for i in adjacents:
		if grid.is_valid_target(i):
			valids.append(i)
	
	return valids


func get_remaining_hits() -> Array:
	var remaining_hits := []
	
	var i := 0
	for cell in grid.cells:
		if cell == grid.States.HIT:
			remaining_hits.append(i)
		i += 1
	
	return remaining_hits
