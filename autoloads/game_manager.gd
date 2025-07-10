extends Node

signal player_info_updated

var players := {}:
	set(value):
		players = value
		player_info_updated.emit()
