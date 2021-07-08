# Manages the two phases and turn order
extends Node


var setups_finished := 0
var is_player_turn: bool # only used during play, not setup
export var attacks_per_turn := 1
var attacks_this_turn := 0

onready var player_board: Board = $Boards/PlayerBoard
onready var enemy_board: Board = $Boards/EnemyBoard
onready var enemy_ai: EnemyAI = $EnemyAI
onready var panel: Panel = $UI/Panel

func _ready() -> void:
	# set enemy_ai parameters/variables
	player_board.connect("all_ships_placed", self, "_on_all_ships_placed")
	enemy_board.connect("all_ships_placed", self, "_on_all_ships_placed")
	player_board.connect("attack_confirmed", self, "_on_attack_confirmed")
	enemy_board.connect("attack_confirmed", self, "_on_attack_confirmed")
	player_board.connect("all_ships_sunk", self, "_on_all_ships_sunk", [player_board])
	enemy_board.connect("all_ships_sunk", self, "_on_all_ships_sunk", [enemy_board])
	panel.show()


func _unhandled_input(event: InputEvent) -> void:
	# DEBUG #
	if event.is_action_pressed("quit_game"):
		get_tree().quit()
	
	if event.is_action_pressed("ui_accept"):
		panel.hide()
		_start_setup()


func _start_setup() -> void:
	player_board.player_start_ship_placement() # create cursor
	enemy_ai.start_ship_placement()


func _on_all_ships_placed() -> void:
	setups_finished += 1
	if setups_finished >= 2:
		_start_player_turn()


func _start_player_turn() -> void:
	is_player_turn = true
	enemy_board.toggle_cursor() # Board's defensive checks should rely on cursor visibility


func _start_enemy_turn() -> void:
	is_player_turn = false
	enemy_board.toggle_cursor()
	enemy_ai.start_turn()


func _on_attack_confirmed() -> void:
	attacks_this_turn += 1
	if attacks_this_turn < attacks_per_turn:
		return
	
	if is_player_turn: _start_enemy_turn()
	else: _start_player_turn()


func _on_all_ships_sunk(board) -> void:
	if board == player_board: _game_over()
	else: _victory()


func _game_over() -> void:
	print("Game over!")


func _victory() -> void:
	print("You win!")
