extends Node

@export var next_scene: PackedScene

var cientista_ready = false
var guardiao_ready = false


func cientista_chegou():
	cientista_ready = true
	print("cientista chegou")
	check_transition()


func cientista_saiu():
	cientista_ready = false
	print("cientista saiu")


func guardiao_chegou():
	guardiao_ready = true
	print("guardiao chegou")
	check_transition()


func guardiao_saiu():
	guardiao_ready = false
	print("guardiao saiu")


func check_transition():

	print(cientista_ready, guardiao_ready)

	if cientista_ready and guardiao_ready:
		print("MUDANDO DE FASE")
		get_tree().change_scene_to_packed(next_scene)
