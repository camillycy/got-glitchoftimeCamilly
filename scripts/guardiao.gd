extends CharacterBody2D

const SPEED = 450
const JUMP_FORCE = -400
const GRAVITY = 900

const FALL_LIMIT = 1200

var spawn_position: Vector2

@onready var animated_sprite = $AnimatedSprite2D


func _ready():
	spawn_position = global_position


func _physics_process(delta):

	# gravidade
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# movimento
	var direction = 0

	if Input.is_action_pressed("ui_left"):
		direction -= 1
	if Input.is_action_pressed("ui_right"):
		direction += 1

	velocity.x = direction * SPEED

	# animação walking
	if direction != 0:
		animated_sprite.play("walking")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.play("default")

	# pulo
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_FORCE

	move_and_slide()

	if global_position.y > FALL_LIMIT:
		respawn()


func respawn():
	global_position = spawn_position
	velocity = Vector2.ZERO
