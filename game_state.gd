extends Node

signal age_changed
signal player_death

var current_age : float = 25.0:
	set(value):
		current_age = value
		age_changed.emit()

var max_age : float = 80.0

var shield : bool = false
