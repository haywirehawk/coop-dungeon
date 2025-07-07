extends Node

signal server_clients_updated(connected_clients: int, max_clients: int)
signal cant_connect_to_server
signal disconnected_from_server
signal players_updated

const SERVER_PORT = 4380
const SERVER_IP = "127.0.0.1"
const MAX_CLIENTS := 4

var player_scene: PackedScene = preload("res://scenes/game_objects/multiplayer/multiplayer_player.tscn")

var _players_spawn_node: Node2D
var host_mode_enabled = false


func become_host() -> void:
	var server_peer = ENetMultiplayerPeer.new()
	var error = server_peer.create_server(SERVER_PORT, MAX_CLIENTS)
	if error == ERR_ALREADY_IN_USE:
		push_error("Attempted to create server. Already in Use")
		return
	if error == ERR_CANT_CREATE:
		push_error("Attempted to create server. Failed to create")
		return
	if error == OK:
		print("Attempted to create server. Success")
	
	server_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = server_peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	send_player_information(multiplayer.get_unique_id(), "Host")
	_players_spawn_node = get_tree().get_first_node_in_group("PlayersLayer")
	host_mode_enabled = true
	
	_add_player_to_game(1)



func join_game() -> void:
	_players_spawn_node = get_tree().get_first_node_in_group("PlayersLayer")
	host_mode_enabled = false
	
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
	
	client_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = client_peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func disconnect_from_server(client_id: int) -> void:
	multiplayer.multiplayer_peer.close()


@rpc("any_peer", "call_remote", "reliable")
func send_player_information(id: int, player_name: String, color: Color = Color.WHITE) -> void:
	if not GameManager.players.has(id):
		GameManager.players[id] = {
			"name": player_name,
			"color": color
		}
	
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(i, GameManager.players[i]["name"], GameManager.players[i]["color"])



func _add_player_to_game(id: int) -> void:
	if not multiplayer.is_server():
		return
	print("Player %s joined the game." % id)
	
	var player_to_add = player_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	print(player_to_add.name)
	
	_players_spawn_node.add_child(player_to_add, true)
	
	server_clients_updated.emit(multiplayer.get_peers().size(), MAX_CLIENTS)


func _remove_player_from_game(id: int) -> void:
	print("Player %s left the game." % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
	
	server_clients_updated.emit(multiplayer.get_peers().size(), MAX_CLIENTS)


#func _remove_single_player() -> void:
	#print("Remove single player")
	#var player_to_remove = get_tree().current_scene.get_node("Player")
	#player_to_remove.queue_free()


func _on_peer_connected(id: int) -> void:
	_add_player_to_game(id)


func _on_peer_disconnected(id: int) -> void:
	_remove_player_from_game(id)


func _on_connected_to_server() -> void:
	send_player_information.rpc_id(1, multiplayer.get_unique_id(), GameManager.players[0].name, GameManager.players[0]["color"])
	#print(str(GameManager.players[0].name))
	pass


func _on_connection_failed() -> void:
	cant_connect_to_server.emit()


func _on_server_disconnected() -> void:
	print("Server Disconnected")
	disconnected_from_server.emit()
	get_tree().reload_current_scene()
