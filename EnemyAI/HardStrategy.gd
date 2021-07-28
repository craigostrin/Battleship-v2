extends Strategy

var even_or_odd: int

func _ready() -> void:
	even_or_odd = rng.randi() % 2
	print(owner.name + ": even or odd is " + str(even_or_odd))


# First try: even or odd should be 0 or 1
func get_random_guess(unguessed_indexes: Array) -> int:
	var success := false
	var random_guess := -1
	
	while success == false:
		var random_index := _get_random_index(unguessed_indexes)
		random_guess = unguessed_indexes[random_index]
		
		var is_row_even = grid.get_row(random_guess) % 2 == 0
		if is_row_even:
			print("row is even")
			success = random_guess
		
		
		success = random_guess % 2
		print("success = " + str(success))
	
	return random_guess


func calculate_next_guesses(next_guesses: Array, last_hit: int, last_last_hit: int) -> Array:
	# Check for already-damaged ships
	if last_hit < 0: # This only happens after a ship is sunk
		var remaining_hits := _get_remaining_hits()
		print("remaining hits: " + str(remaining_hits))
		
		if remaining_hits.empty():
			return next_guesses
		else:
			for hit in remaining_hits:
				var valid_adjacents := _get_valid_adjacents(hit)
				next_guesses.append_array(valid_adjacents)
			print("added adjacents for remaining hits: " + str(next_guesses))
			return next_guesses
	
	
	var valid_adjacents := _get_valid_adjacents(last_hit)
	next_guesses.append_array(valid_adjacents)
	print("added adjacent cells " + str(valid_adjacents) + " to next guesses")
	
	next_guesses.shuffle()
	
	# Check for consecutive hits and move cells in the same col/row to the front of the array
	if last_hit >= 0 and last_last_hit >= 0:
		var last_hit_column = grid.get_column(last_hit)
		var last_hit_row = grid.get_row(last_hit)
		var same_column = last_hit_column == grid.get_column(last_last_hit)
		var same_row = last_hit_row == grid.get_row(last_last_hit)
		
		if same_column:
			print("2 hits in same column!")
			for index in next_guesses:
				var index_column = grid.get_column(index)
				if index_column == last_hit_column:
					next_guesses.erase(index)
					next_guesses.push_front(index)
		
		if same_row:
			print("2 hits in same row!")
			for index in next_guesses:
				var index_row = grid.get_row(index)
				if index_row == last_hit_row:
					next_guesses.erase(index)
					next_guesses.push_front(index)
	
	print("next guesses: " + str(next_guesses))
	return next_guesses
