extends Strategy


# Might just totally redo this but....

# Two things:
# 1. What if you pushfront the same-row/column cells? So it prioritizes those without getting rid of the other adjacents
# 2. How to find damaged ships after one is sunk? Just find *all* HIT cells and add their adjacents to the list?

func calculate_next_guesses(next_guesses: Array, last_hit: int, last_last_hit: int) -> Array:
# THIS IS BROKEN BECAUSE IT ONLY FINDS THE FIRST HIT, WHICH COULD BE SURROUNDED BY INVALID TARGETS
#	# Check for unsunk, damaged ships
#	if last_hit < 0:
#		last_hit = grid.cells.find(grid.States.HIT) # returns -1 if none found
#		print("Found old last hit " + str(last_hit))
#
#	# If no unsunk damaged ships found, let the AI default to a random guess
#	if last_hit < 0:
#		print("No last hit found")
#		return next_guesses
	
	if last_hit < 0: # This only happens after a ship is sunk
		var remaining_hits := get_remaining_hits()
		print("remaining hits: " + str(remaining_hits))
		
		if remaining_hits.empty():
			return next_guesses
		else:
			for hit in remaining_hits:
				var valid_adjacents := get_valid_adjacents(hit)
				next_guesses.append_array(valid_adjacents)
			print("added adjacents for remaining hits: " + str(next_guesses))
			return next_guesses
	
	var valid_adjacents := get_valid_adjacents(last_hit)
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


# These are now on the base Strategy class so Hard can use them
#func get_valid_adjacents(index: int) -> Array:
#	var valids := []
#	var adjacents := grid.get_adjacents(index)
#
#	for i in adjacents:
#		if grid.is_valid_target(i):
#			valids.append(i)
#
#	return valids


#func get_remaining_hits() -> Array:
#	var remaining_hits := []
#
#	var i := 0
#	for cell in grid.cells:
#		if cell == grid.States.HIT:
#			remaining_hits.append(i)
#		i += 1
#
#	return remaining_hits
