class_name Board
extends Node2D

signal ship_placed
signal ship_not_placed(ship) #used by EnemyAI to try again
signal all_ships_placed
signal attack_confirmed
signal all_ships_sunk

export var is_enemy_board := false

var ship_lengths := [5, 4, 3, 3, 2]
var placed_ships := []
var ship_index := 0

export var grid: Resource = preload("res://PlayerGrid.tres")
export var default_sprite: Texture = preload("res://Art/water.png")
export var hit_sprite: Texture = preload("res://Art/hit_transparent.png")
export var miss_sprite: Texture = preload("res://Art/miss.png")

onready var _cursor: Cursor = $Cursor


func _ready() -> void:
	grid.initialize_grid()
	initialize_sprites()
	_cursor.board_position = position


func initialize_sprites() -> void:
	var index := 0
	for cell in grid.cells:
		create_sprite_at_index(default_sprite, index)
		index += 1


func player_start_ship_placement() -> void:
	toggle_cursor()


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
	
	ship.position = grid.calculate_board_position(index)
	add_child(ship)
#	if is_enemy_board: DEBUG
#		ship.hide()
	
	#print("placed " + ship.name + " at " + str(index) + " on " + name)


# Move this to Grid.gd if another class ever needs to use it
# For now I think it's fine here 
func _are_cells_empty(index_array: PoolIntArray) -> bool:
	var are_empty := true
	
	for index in index_array:
		if not grid.is_cell_empty(index):
			are_empty = false
			break
	
	return are_empty

#func player_get_next_ship() -> Ship:
#	var ship: Ship
#
#	return ship


func toggle_cursor() -> void:
	_cursor.visible = !_cursor.visible
	_cursor.set_process_unhandled_input(_cursor.visible)


func create_sprite_at_index(texture: Texture, index: int) -> void:
	var sprite = Sprite.new()
	sprite.position = grid.calculate_board_position(index)
	sprite.texture = texture
	$Sprites.add_child(sprite)
