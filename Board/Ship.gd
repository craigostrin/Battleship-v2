class_name Ship
extends Node2D

signal ship_sunk

const MIN_LENGTH = 2
const MAX_LENGTH = 5
const CELL_WIDTH = 32

var length: int
var is_vertical := false setget _set_is_vertical
var index_array := []

var _hits: int
var is_sunk := false

var _end_sprite: Texture = preload("res://Art/ship_end.png")
var _mid_sprite: Texture = preload("res://Art/ship_middle.png")


func _init(_length: int) -> void:
	length = clamp(_length, MIN_LENGTH, MAX_LENGTH)
	name = "Ship-" + str(length)


func _ready() -> void:
	for index in length:
		var sprite = Sprite.new()
		sprite.position.x = index * CELL_WIDTH
		sprite.texture = _mid_sprite
		add_child(sprite)
	
	var sprites = get_children()
	sprites[0].texture = _end_sprite
	sprites[sprites.size() - 1].texture = _end_sprite
	sprites[sprites.size() - 1].rotation_degrees = 180


func hit():
	_hits += 1
	if _hits >= length:
		is_sunk = true
		show()
		modulate = Color.black
		emit_signal("ship_sunk")


func _set_is_vertical(value) -> void:
	is_vertical = value
	
	if is_vertical:
		rotation_degrees = 90
	else:
		rotation_degrees = 0
