# Player-controlled cursor. Allows them to navigate the game grid, select units, and move them.
# Supports both keyboard and mouse (or touch) input.
class_name Cursor
extends Node2D

signal moved(new_index)
signal accept_pressed(index)

export var cursor_texture: Texture = preload("res://Art/cursor.png")

# preload for DEBUG
var grid: Resource = preload("res://PlayerGrid.tres")
export var ui_cooldown := 0.1
var board_position := Vector2.ZERO

const BOUND_MARGIN := 0.1 # needed so the right and bot sides don't wrap
var _left_bound: float
var _right_bound: float
var _top_bound: float
var _bot_bound: float

var index := 0 setget set_index

onready var _sprite: Sprite = $Sprite
onready var _timer: Timer = $Timer


func _ready() -> void:
	yield(owner, "ready") # wait for Board to set board_position = its position
	set_bounds()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	if event is InputEventMouseMotion:
		if (event.position.x < _left_bound
			or event.position.x > _right_bound
			or event.position.y < _top_bound
			or event.position.y > _bot_bound):
				return
		
		self.index = grid.calculate_index_from_board_position(event.position, board_position)
	
	elif event.is_action_pressed("ui_accept"):
		get_tree().set_input_as_handled()
		emit_signal("accept_pressed", index)
		print("clicked " + str(index))
	
	# Make some preliminary checks to see whether the cursor should move if user presses an arrow key
	var should_move := event.is_pressed()
	
	# If the player is pressing the key in this frame, we allow the cursor to move. If they keep the
	# keypress down (is_echo), we only want to move after the cooldown timer stops.
	if event.is_echo():
		should_move = should_move and _timer.is_stopped()
	
	if not should_move:
		return
	
	if event.is_action("ui_right") and grid.get_column(index) < grid.columns - 1:
		self.index += grid.Directions.RIGHT
	elif event.is_action("ui_up") and grid.get_row(index) > 0:
		self.index += grid.Directions.UP
	elif event.is_action("ui_left") and grid.get_column(index) > 0:
		self.index += grid.Directions.LEFT
	elif event.is_action("ui_down") and grid.get_row(index) < grid.rows - 1:
		self.index += grid.Directions.DOWN


func set_index(value: int) -> void:
	var new_index: int = grid.clamp(value)
	if new_index == index:
		return
	
	index = new_index
	position = grid.calculate_board_position(index)
	
	emit_signal("moved", index)
	_timer.start(ui_cooldown)


func set_bounds() -> void:
	if not grid:
		printerr("set_bounds(): Missing Grid resource assigned to cursor.")
		return
	
	var cell_size: Vector2 = grid.cell_size
	var board_width: float = cell_size.x * grid.columns
	var board_height: float = cell_size.y * grid.rows
	
	_left_bound = board_position.x
	_right_bound = _left_bound + board_width - BOUND_MARGIN
	_top_bound = board_position.y
	_bot_bound = _top_bound + board_height - BOUND_MARGIN
