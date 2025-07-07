extends Node

@export var player_scene: PackedScene


func _ready() -> void:
	var index = 0
	for i in GameManager.players:
		var current_player = player_scene.instantiate()
		current_player.name = str(GameManager.players[i].id)
		current_player.player_name = GameManager.players[i].name
		current_player.set_player_color(GameManager.players[i]["color"])
		for spawn in get_tree().get_nodes_in_group("PlayerSpawn"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
		add_child(current_player)
		index += 1
