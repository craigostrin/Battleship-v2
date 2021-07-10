class_name Board
extends Node2D

signal ship_placed
signal ship_not_placed(ship) #used by EnemyAI to try again
signal attack_confirmed
signal all_ships_sunk

export var is_player_controlled_board := true

var ship_lengths := [5, 4, 3, 3, 2]
var placed_ships := []
var ship_index := placed_ships.size()

export var grid: Resource = preload("res://PlayerGrid.tres")
export var default_sprite: Texture = preload("res://Art/water.png")
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
		attack(index)


func attack(index: int) -> void:
	if _cursor.ship_placer:
		return
	
	
	emit_signal("attack_confirmed")


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
	add_child(ship)
	placed_ships.append(ship)
	ship_index = placed_ships.size() # Will this work???
	emit_signal("ship_placed")
#	if not is_player_controlled_board: DEBUG
#		ship.hide()
	
	print("placed " + ship.name + " at " + str(index) + " on " + name)


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


func toggle_cursor() -> void:
	_cursor.visible = !_cursor.visible
	_cursor.set_process_unhandled_input(_cursor.visible)


func create_sprite_at_index(texture: Texture, index: int) -> void:
	var sprite = Sprite.new()
	sprite.position = grid.calculate_board_position(index)
	sprite.texture = texture
	$Sprites.add_child(sprite)
