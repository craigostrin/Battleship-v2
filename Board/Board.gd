class_name Board
extends Node2D

signal next_ship_requested
signal ship_not_placed(ship) # used by EnemyAI to try again
signal all_ships_placed
signal target_confirmed(index) # index used by EnemyAI to keep track of attacked cells
signal target_not_confirmed
signal all_ships_sunk

export var is_player_controlled := true

var ship_lengths := [5, 4, 3, 3, 2]
var placed_ships := []
var ship_index := placed_ships.size()

var targeted_cells := {}
var ships_sunk := 0

export var grid: Resource = preload("res://PlayerGrid.tres")
export var default_sprite: Texture = preload("res://Art/water.png")
export var target_sprite: Texture = preload("res://Art/target.png")
export var hit_sprite: Texture = preload("res://Art/hit_transparent.png")
export var miss_sprite: Texture = preload("res://Art/miss.png")

onready var _cursor: Cursor = $Cursor


func _ready() -> void:
	grid.initialize_grid()
	initialize_sprites()
	_cursor.board_position = position
	_cursor.connect("accept_pressed", self, "_on_accept_pressed")


func initialize_sprites() -> void:
	var index := 0
	for cell in grid.cells:
		create_sprite_at_index(default_sprite, index)
		index += 1


func _on_accept_pressed(index: int) -> void:
	if _cursor.ship_placer:
		var ship: Ship = _cursor.ship_placer
		place_ship(ship, index)
	else:
		#attack(index)
		target_cell(index)


func target_cell(index: int) -> void:
	if _cursor.ship_placer:
		return
	
	var targeted_cell = grid.cells[index]
	
	if targeted_cell == grid.States.HIT or targeted_cell == grid.States.MISS or index in targeted_cells:
		emit_signal("target_not_confirmed")
		return
	
	var sprite = create_sprite_at_index(target_sprite, index)
	targeted_cells[index] = sprite
	emit_signal("target_confirmed")


func attack_targeted_cells() -> void:
	for index in targeted_cells.keys():
		var sprite = targeted_cells[index]
		sprite.queue_free()
		attack(index)
	
	targeted_cells.clear()


func attack(index: int) -> void:
	var cell = grid.cells[index]
	
	if cell == grid.States.EMPTY:
		cell = grid.States.MISS
		create_sprite_at_index(miss_sprite, index)
	
	if cell == grid.States.SHIP:
		cell = grid.States.HIT
		var ship = get_ship_at_index(index)
		ship.hit()
		create_sprite_at_index(hit_sprite, index)
	
	grid.cells[index] = cell


func _on_ship_sunk() -> void:
	ships_sunk += 1
	if ships_sunk >= placed_ships.size():
		emit_signal("all_ships_sunk")


func toggle_ships_revealed() -> void:
	for ship in placed_ships:
		if not ship.is_sunk:
			ship.visible = !ship.visible


# Everything that calls this should be using grid.clamp_ship_placement beforehand
func place_ship(ship: Ship, index: int) -> void:
	var length := ship.length
	var is_vertical := ship.is_vertical
	var index_array: PoolIntArray = grid.get_ship_index_array(index, length, is_vertical)
	
	if not _are_cells_empty(index_array):
		emit_signal("ship_not_placed", ship)
		return
	
	for i in index_array:
		grid.cells[i] = grid.States.SHIP
	
	if _cursor.ship_placer:
		_cursor.remove_child(ship)
	
	ship.position = grid.calculate_board_position(index)
	ship.index_array = index_array
	add_child(ship)
	placed_ships.append(ship)
	ship.connect("ship_sunk", self, "_on_ship_sunk")
	
	ship_index = placed_ships.size() # I guess this works?
	
	print(name + " placed " + ship.name + " at " + str(index_array))
	
	if not is_player_controlled:
		ship.hide()
	
	if placed_ships.size() >= ship_lengths.size():
		emit_signal("all_ships_placed")
	
	elif is_player_controlled:
		emit_signal("next_ship_requested")


func get_next_ship_placer() -> Ship:
	var next_ship: Ship
	
	if ship_index >= ship_lengths.size():
		printerr("Get_next_ship_placer returned 'null'. All ships already placed.")
		return next_ship
	
	var length = ship_lengths[ship_index]
	next_ship = Ship.new(length)
	
	return next_ship


func assign_ship_placer(ship: Ship) -> void:
	_cursor.ship_placer = ship


func clear_ship_placer() -> void:
	if _cursor.ship_placer:
		_cursor.ship_placer = null


# Move this to Grid.gd if another class ever needs to use it (fine here for now)
func _are_cells_empty(index_array: PoolIntArray) -> bool:
	var are_empty := true
	
	for index in index_array:
		if not grid.is_cell_empty(index):
			are_empty = false
			break
	
	return are_empty


func get_ship_at_index(index: int) -> Ship:
	var ship: Ship
	
	for _ship in placed_ships:
		if _ship.index_array.has(index):
			ship = _ship
	
	return ship


func show_cursor(value: bool) -> void:
	_cursor.visible = value
	_cursor.set_process_unhandled_input(value)


func create_sprite_at_index(texture: Texture, index: int) -> Sprite:
	var sprite = Sprite.new()
	sprite.position = grid.calculate_board_position(index)
	sprite.texture = texture
	add_child(sprite)
	return sprite
