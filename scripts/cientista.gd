extends CharacterBody2D

const SPEED = 450
const JUMP_FORCE = -400
const GRAVITY = 900

const FALL_LIMIT = 1200

var move_left = false
var move_right = false
var jump = false

var spawn_position: Vector2

@onready var animated_sprite = $AnimatedSprite2D


func _ready():
	set_process_input(true)
	spawn_position = global_position


func _input(event):

	if event.is_action_pressed("move_left_cientista"):
		move_left = true
	if event.is_action_released("move_left_cientista"):
		move_left = false

	if event.is_action_pressed("move_right_cientista"):
		move_right = true
	if event.is_action_released("move_right_cientista"):
		move_right = false

	if event.is_action_pressed("jump_cientista"):
		jump = true


func _physics_process(delta):

	# gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# movimento
	var direction = 0

	if move_left:
		direction -= 1
	if move_right:
		direction += 1

	velocity.x = direction * SPEED

	# animação walking
	if direction != 0:
		animated_sprite.play("walking")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.play("default")

	# pulo
	if jump and is_on_floor():
		velocity.y = JUMP_FORCE
		jump = false

	move_and_slide()

	if global_position.y > FALL_LIMIT:
		respawn()


func respawn():
	global_position = spawn_position
	velocity = Vector2.ZERO
