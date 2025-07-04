extends CharacterBody2D
class_name MultiplayerPlayer

const PLAYER_PALETTE = preload("res://resources/player_palette.tres")

@export var player_id := 1:
	set(id):
		player_id = id
		%InputSynchronizer.set_multiplayer_authority(id)

@export var move_speed: float = 50
@export var do_action: bool = false

@onready var animated_sprite: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var direction_arrow: Sprite2D = $DirectionArrow

var direction: Vector2
var movement_deadzone := 20


func _ready() -> void:
	#animated_sprite.self_modulate =  PLAYER_PALETTE.colors.get(randi_range( 0, PLAYER_PALETTE.colors.size() - 1))
	#animated_sprite.self_modulate = PLAYER_PALETTE.colors.get(get_tree().get_nodes_in_group("Player").size() - 1)
	if multiplayer.get_unique_id() == player_id:
		$Camera2D.make_current()
	else:
		$Camera2D.enabled = false


func _physics_process(delta: float) -> void:
	#get_input_states()
	if multiplayer.is_server():
		get_input()
		apply_movement(delta)
		move_and_slide()
	#else:
		#predict_movement_from_input(delta)

	if not multiplayer.is_server() or MultiplayerManager.host_mode_enabled:
		set_animation()
	if do_action:
		interact()
	
	update_directional_arrow()

# TODO: Predictive movement on client. First attempt did not account for authority.
#func get_local_movement_input() -> void:
	#var horizontal = Input.get_axis("move_left", "move_right")
	#var vertical = Input.get_axis("move_up", "move_down")
	#direction = Vector2(horizontal, vertical)
	#
#
#
#func predict_movement_from_input(delta: float) -> void:
	#get_local_movement_input()
	#apply_movement(delta)


func get_input() -> void:
	direction = %InputSynchronizer.input_direction


func apply_movement(delta: float) -> void:
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


func update_directional_arrow() -> void:
	direction_arrow.look_at(%InputSynchronizer.mouse_location)
	direction_arrow.rotate(PI/2)


func interact() -> void:
	animated_sprite.play("action")
	do_action = false


func set_player_color(color: Color) -> void:
	animated_sprite.self_modulate = color
