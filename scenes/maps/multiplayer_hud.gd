extends Node

@onready var host_game_button: Button = $Panel/VBoxContainer/HostGame
@onready var join_game_button: Button = $Panel/VBoxContainer/JoinGame
@onready var multiplayer_hud: Control = $"."


func _ready() -> void:
	host_game_button.pressed.connect(become_host)
	join_game_button.pressed.connect(join_game)


func become_host() -> void:
	print("Become Host Pressed")
	multiplayer_hud.hide()
	MultiplayerManager.become_host()


func join_game() -> void:
	print("Join Game Pressed")
	multiplayer_hud.hide()
	MultiplayerManager.join_game()
