extends CharacterBody2D

var speed = 200

@onready var anim = $AnimatedSprite2D

func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")

	velocity.x = direction * speed

	if direction != 0:
		anim.play("walk")
	else:
		anim.play("idle")

	move_and_slide()
