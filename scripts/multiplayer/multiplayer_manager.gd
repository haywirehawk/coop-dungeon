extends Node

const SERVER_PORT = 4380
const SERVER_IP = "127.0.0.1"

var multiplayer_scene: PackedScene = preload("res://scenes/game_objects/multiplayer/multiplayer_player.tscn")

var _players_spawn_node: Node2D
var host_mode_enabled = false


func become_host() -> void:
	print("Starting host!")
	
	_players_spawn_node = get_tree().current_scene.get_node("Players")
	host_mode_enabled = true
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_remove_player_from_game)
	
	_remove_single_player()
	_add_player_to_game(1)



func join_game() -> void:
	print("Joining as Player 2")
	
	var client_peer = ENetMultiplayerPeer.new()
	var client_error = client_peer.create_client(SERVER_IP, SERVER_PORT)
	if client_error == ERR_ALREADY_IN_USE:
		push_error("Attempted to create client. Already in Use")
		return
	if client_error == ERR_CANT_CREATE:
		push_error("Attempted to create client. Failed to create")
		return
	if client_error == OK:
		print("Attempted to create client. Success")
	
	
	multiplayer.multiplayer_peer = client_peer
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	_remove_single_player()


func _add_player_to_game(id: int) -> void:
	print("Player %s joined the game." % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add, true)


func _remove_player_from_game(id: int) -> void:
	print("Player %s left the game." % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()


func _remove_single_player() -> void:
	print("Remove single player")
	var player_to_remove = get_tree().current_scene.get_node("Player")
	player_to_remove.queue_free()


func _on_server_disconnected() -> void:
	print("Server Disconnected")
	get_tree().reload_current_scene()
