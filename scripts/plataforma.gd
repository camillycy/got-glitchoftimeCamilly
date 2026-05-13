extends Node2D

@onready var anim = $AnimationPlayer

func activate_platform():

	anim.play("rise")
