extends Strategy


func calculate_next_guesses(next_guesses: Array, last_hit: int, last_last_hit: int) -> Array:
	var adjacents = grid.get_adjacents(last_hit)
	for index in adjacents:
		var adjacent_cell = grid.cells[index]
		if not adjacent_cell == grid.States.HIT or adjacent_cell == grid.States.MISS:
			next_guesses.append(index)
	
	# Check for consecutive hits
	if last_hit >= 0 and last_last_hit >= 0:
		var last_hit_column = grid.get_column(last_hit)
		var last_hit_row = grid.get_row(last_hit)
		var same_column = last_hit_column == grid.get_column(last_last_hit)
		var same_row = last_hit_row == grid.get_row(last_last_hit)
		
		if same_column:
			for index in next_guesses:
				if not grid.get_column(index) == last_hit_column:
					print(str(index) + " does not share a column with " + str(last_hit))
					next_guesses.erase(index)
			print("2 hits in same column!")
		
		if same_row:
			for index in next_guesses:
				if not grid.get_row(index) == last_hit_row:
					print(str(index) + " does not share a row with " + str(last_hit))
					next_guesses.erase(index)
			print("2 hits in same row!")
	
	print("next guesses: " + str(next_guesses))
	return next_guesses
