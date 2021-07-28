extends Strategy


func calculate_next_guesses(next_guesses: Array, last_hit: int, last_last_hit: int) -> Array:
	var valid_adjacents := _get_valid_adjacents(last_hit)
	next_guesses.append_array(valid_adjacents)
	print("added adjacent cells " + str(valid_adjacents) + " to next guesses")
	
	next_guesses.shuffle()
	
	return next_guesses
