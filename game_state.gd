extends Node

signal age_changed
signal shield_changed
signal player_death

var current_age : float = 25.0:
	set(value):
		current_age = value
		age_changed.emit()

var max_age : float = 80.0

var shield : float = 0.0:
	set(value):
		shield = value
		shield_changed.emit()
