extends Node

@onready var connection_information: Control = %ConnectionInformation
@onready var connected_peers: Label = %ConnectedPeers

@onready var start_multiplayer_menu: Control = %StartMultiplayerMenu
@onready var name_container: HBoxContainer = %NameContainer
@onready var name_input: LineEdit = %NameInput
@onready var color_picker_container: HBoxContainer = %ColorPickerContainer
@onready var host_game_button: Button = %HostGame
@onready var join_game_button: Button = %JoinGame

@onready var server_status_popover: Control = %ServerStatusPopover
@onready var server_status_label: Label = %ServerStatusLabel
@onready var disconnect_button: Button = %DisconnectButton
@onready var close_button: Button = %CloseButton


func _ready() -> void:
	MultiplayerManager.server_clients_updated.connect(_on_server_clients_updated)
	MultiplayerManager.cant_connect_to_server.connect(_on_cant_connect_to_server)
	MultiplayerManager.disconnected_from_server.connect(_on_disconnected_from_server)
	
	host_game_button.pressed.connect(_on_host_game_button_pressed)
	join_game_button.pressed.connect(_on_join_game_button_pressed)
	disconnect_button.pressed.connect(_on_disconnect_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	
	connection_information.hide()
	start_multiplayer_menu.show()
	server_status_popover.hide()


func _on_host_game_button_pressed() -> void:
	print("Become Host Pressed")
	start_multiplayer_menu.hide()
	#show_status_popover()
	#update_player_information()
	MultiplayerManager.become_host()


func _on_join_game_button_pressed() -> void:
	print("Join Game Pressed")
	start_multiplayer_menu.hide()
	#show_status_popover()
	#update_player_information()
	MultiplayerManager.join_game()


func show_status_popover() -> void:
	if multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		close_button.hide()
		disconnect_button.show()
		server_status_label.text = "Connecting to lobby."
	else:
		close_button.show()
		disconnect_button.hide()
		server_status_label.text = "You did not connect to the server."
	
	server_status_popover.show()


func update_player_information() -> void:
	GameManager.players[0] = {
		"name": name_input.text,
		"color": color_picker_container.chosen_color
	}


#region Button Signal Handling

func _on_disconnect_button_pressed() -> void:
	server_status_popover.hide()
	MultiplayerManager.disconnect_from_server(multiplayer.get_unique_id())


func _on_close_button_pressed() -> void:
	server_status_popover.hide()

#endregion
#region Server Signal Handling

func _on_server_clients_updated(connected_clients: int, max_clients: int) -> void:
	server_status_label.text = "%d/%d peers connected." % [connected_clients, max_clients]


func _on_cant_connect_to_server() -> void:
	server_status_label.text = "Could not connect to server."


func _on_disconnected_from_server() -> void:
	pass
#endregion
