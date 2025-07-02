extends CharacterBody2D
class_name MultiplayerPlayer


@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

@export var move_speed: float = 50
@export var do_action: bool = false
const PLAYER_PALETTE = preload("res://resources/player_palette.tres")


@onready var animated_sprite: AnimatedSprite2D = $Visuals/AnimatedSprite2D

var direction: Vector2
var movement_deadzone := 20


func _ready() -> void:
	#animated_sprite.self_modulate =  PLAYER_PALETTE.colors.get(randi_range( 0, PLAYER_PALETTE.colors.size() - 1))
	animated_sprite.self_modulate = PLAYER_PALETTE.colors.get(get_tree().get_nodes_in_group("Player").size() - 1)
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false


func _physics_process(delta: float) -> void:
	#get_input_states()
	if multiplayer.is_server():
		apply_movement_from_input(delta)

	if not multiplayer.is_server() or MultiplayerManager.host_mode_enabled:
		set_animation()
	move_and_slide()
	if do_action:
		interact()


func apply_movement_from_input(delta: float) -> void:
	direction = %InputSynchronizer.input_direction
	
	if direction:
		velocity = direction * move_speed
	else:
		velocity = lerp(velocity, Vector2.ZERO, 1 - exp(-12 * delta))


func set_animation() -> void:
	if direction == Vector2.ZERO:
		animated_sprite.play("default")
	else:
		animated_sprite.play("move")
	var move_sign = sign(direction.x)
	if move_sign != 0:
		$Visuals.scale = Vector2(move_sign, 1)


func interact() -> void:
	animated_sprite.play("action")
	do_action = false
