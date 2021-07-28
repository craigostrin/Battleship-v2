# Manages the two phases and turn order
extends Node

# I'm cheating a bit so I don't have to refactor a bunch:
# Left board will always go first, and left board will always be a player in singleplayer matches

var setups_finished := 0
var is_left_turn: bool # only used during play, not setup
export var attacks_per_turn := 1
var attacks_this_turn := 0

var enemy_ais := []
var enemy_ai_scene = preload("res://EnemyAI/EnemyAI.tscn")
var left_enemy_ai: EnemyAI
var right_enemy_ai: EnemyAI

onready var left_board: Board = $Boards/LeftBoard
onready var right_board: Board = $Boards/RightBoard
onready var panel := $UI/Panel
onready var _ui := $UI
onready var _game_over_label := $UI/GameOverPanel/Label


func _ready() -> void:
	var boards = [left_board, right_board]
	_connect_signals(boards)
	
	right_board.is_player_controlled = true
	_setup_enemy_ai(left_board)
	_setup_enemy_ai(right_board)
	left_enemy_ai.set_strategy(3)
	right_enemy_ai.set_strategy(3)
	
	panel.show()


func _unhandled_input(event: InputEvent) -> void:
	# DEBUG #
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
	
	if panel.visible and event.is_action_pressed("ui_accept"):
		panel.hide()
		_start_setup()


func _setup_enemy_ai(my_board: Board) -> void:
	var ai = enemy_ai_scene.instance()
	var opponent_board: Board = right_board if my_board == left_board else left_board
	
	ai.init(my_board, opponent_board)
	my_board.is_player_controlled = false
	
	enemy_ais.append(ai)
	
	if my_board == right_board: right_enemy_ai = ai
	else: left_enemy_ai = ai
	
	ai.name = my_board.name + ai.name
	add_child(ai)


# Must be done AFTER Enemy AIs are setup
func _connect_signals(boards: Array) -> void:
	for board in boards:
		board.connect("next_ship_requested", self, "_on_next_ship_requested", [board])
		board.connect("all_ships_placed", self, "_on_all_ships_placed", [board])
		board.connect("target_confirmed", self, "_on_target_confirmed", [board])
		board.connect("all_ships_sunk", self, "_on_all_ships_sunk", [board])


func _start_setup() -> void:
	if left_board.is_player_controlled:
		left_board.show_cursor(true)
		_player_ship_placement(left_board)
	
	for ai in enemy_ais:
		ai.start_ship_placement()


func _player_ship_placement(board: Board):
	var ship = board.get_next_ship_placer()
	if ship:
		board.assign_ship_placer(ship)


func _on_next_ship_requested(board: Board):
	if board.is_player_controlled:
		_player_ship_placement(board)


func _on_all_ships_placed(board: Board) -> void:
	setups_finished += 1
	if board.is_player_controlled:
		board.clear_ship_placer()
		board.show_cursor(false)
		board.reveal_ships(false)
	
	# left_board is hardcoded to always go first
	if right_board.is_player_controlled and setups_finished == 1:
		right_board.show_cursor(true)
		_player_ship_placement(right_board)

	if setups_finished >= 2:
		_start_left_turn()


func _start_left_turn() -> void:
	# DEBUG
	if left_board.is_player_controlled:
		print("-------------")
		print("Player turn start")
	_ui.turn += 1
	attacks_this_turn = 0
	is_left_turn = true
	left_board.show_cursor(false)
	
	if left_enemy_ai:
		left_enemy_ai.start_turn(attacks_per_turn)
	else:
		right_board.show_cursor(true)


func _start_right_turn() -> void:
	attacks_this_turn = 0
	is_left_turn = false
	right_board.show_cursor(false)
	
	if right_enemy_ai:
		right_enemy_ai.start_turn(attacks_per_turn)
	else:
		left_board.show_cursor(true)


# _index_ isn't used; the signal passes it for EnemyAI to use
func _on_target_confirmed(_index_, board: Board) -> void:
	attacks_this_turn += 1
	if attacks_this_turn < attacks_per_turn:
		return
	else:
		board.attack_targeted_cells()
	
	if is_left_turn: _start_right_turn()
	else: _start_left_turn()


func _on_all_ships_sunk(board: Board) -> void:
	_game_over(board)


func _game_over(losing_board: Board) -> void:
	get_tree().paused = true
	var winning_board := ""
	
	if losing_board == right_board:
		winning_board = "Player 1"
	else:
		winning_board = "Player 2"
	
	_game_over_label.text = winning_board + " won!"
	$UI/GameOverPanel.show()


func _on_LeftRevealShipsButton_toggled(button_pressed: bool) -> void:
	left_board.reveal_ships(button_pressed)


func _on_RightRevealShipsButton_toggled(button_pressed: bool) -> void:
	right_board.reveal_ships(button_pressed)
