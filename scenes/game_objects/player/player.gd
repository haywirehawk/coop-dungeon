extends CharacterBody2D
class_name Player

@export var move_speed: float = 50

@onready var animated_sprite: AnimatedSprite2D = $Visuals/AnimatedSprite2D

# Inputs
var input_left := false
var input_right := false
var input_down := false
var input_up := false

var movement_deadzone := 20


func _physics_process(delta: float) -> void:
	#get_input_states()
	handle_movement()
	set_animation()
	move_and_slide()


func get_input_states() -> void:
	input_left = Input.is_action_pressed("move_left")
	input_right = Input.is_action_pressed("move_right")
	input_down = Input.is_action_pressed("move_down")
	input_up = Input.is_action_pressed("move_up")


func handle_movement() -> void:
	var horizontal = Input.get_axis("move_left", "move_right")
	var vertical = Input.get_axis("move_up", "move_down")
	velocity = Vector2(horizontal, vertical).normalized() * move_speed


func set_animation() -> void:
	if abs(velocity.x) < movement_deadzone and abs(velocity.y) < movement_deadzone:
		animated_sprite.play("default")
	else:
		animated_sprite.play("move")
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		$Visuals.scale = Vector2(move_sign, 1)
