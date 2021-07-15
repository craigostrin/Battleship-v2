extends CanvasLayer

signal left_ships_revealed(button_pressed)

onready var _timer_label := $TimerPanel/Label
onready var _countdown := $TimerPanel/Timer

var time_elapsed := 0.0

func _process(delta: float) -> void:
	time_elapsed += delta
	_timer_label.text = _format_seconds(time_elapsed)


func _format_seconds(time: float) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)
	
	return "%02d:%02d" % [minutes, seconds]


func _on_LeftRevealShipsButton_toggled(button_pressed: bool) -> void:
	emit_signal("left_ships_revealed", button_pressed)
