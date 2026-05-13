extends Node2D

var player_near = false

@onready var label = $Label


func _ready():

	label.visible = false


func _process(delta):

	if player_near:

		label.visible = true

	if Input.is_action_just_pressed("interact_cientista"):

		if Global.arvore_consertada:

			print("A ponte voltou! O que sera que aconteceu?")

		else:

			print("Puxa, a ponte se quebrou depois desse tremor...")


func _on_area_2d_body_entered(body):

	if body.name == "Cientista":
		player_near = true


func _on_area_2d_body_exited(body):
	if body.name == "Cientista":
		player_near = false
