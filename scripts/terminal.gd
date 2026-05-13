extends Node2D

var player_near = false
var activated = false

@export var platform_path : NodePath

var platform

@onready var off_sprite = $Sprite2D
@onready var anim = $AnimatedSprite2D


func _ready():

	anim.visible = false

	platform = get_node(platform_path)


func _process(delta):

	if player_near:
		print("player perto")

	if player_near and Input.is_action_just_pressed("interact_cientista") and not activated:

		print("ativou")

		activated = true

		off_sprite.visible = false
		anim.visible = true

		anim.play("activate")

		platform.activate_platform()


func _on_area_2d_body_entered(body):
	print("algo entrou")

	if body.name == "Cientista":
		print(body.name)
		player_near = true


func _on_area_2d_body_exited(body):

	if body.name == "Cientista":
		player_near = false
