class_name Board
extends Node2D

signal all_ships_placed
signal attack_confirmed
signal all_ships_sunk

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


func start_player_ship_placement() -> void:
	toggle_cursor()


func toggle_cursor() -> void:
	_cursor.visible = !_cursor.visible


func create_sprite_at_index(texture: Texture, index: int) -> void:
	var sprite = Sprite.new()
	sprite.position = grid.calculate_board_position(index)
	sprite.texture = texture
	$Sprites.add_child(sprite)
