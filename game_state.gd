extends Node

signal age_changed
signal shield_changed
signal player_death


var current_age : float = 25.0:
	set(value):
		current_age = value
		age_changed.emit()

var max_age : float = 80

var shield : float = 0.0:
	set(value):
		shield = value
		shield_changed.emit()
		
func reset():
	current_age = 25.0
	max_age = 80.0
	shield = 0.0
