extends MultiplayerSynchronizer

@onready var player = $".."

var input_direction := Vector2.ZERO
var mouse_location := Vector2.ZERO


func _ready() -> void:
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	_get_input_direction()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		do_action.rpc()


func _physics_process(delta: float) -> void:
	_get_input_direction()
	_get_mouse_location()


func _get_input_direction() -> void:
	var horizontal = Input.get_axis("move_left", "move_right")
	var vertical = Input.get_axis("move_up", "move_down")
	input_direction = Vector2(horizontal, vertical)


func _get_mouse_location() -> void:
	mouse_location = player.get_global_mouse_position()


@rpc("call_local")
func do_action() -> void:
	if multiplayer.is_server():
		player.do_action = true
