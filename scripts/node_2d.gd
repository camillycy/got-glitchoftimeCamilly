extends Node2D

func _ready():
	await get_tree().process_frame

	print(get_tree().get_root().get_children()) # DEBUG

	var fase = get_node("Fase1")
	print(fase)

	var up = $CanvasLayer.get_child(0).get_child(0)
	var down = $CanvasLayer.get_child(1).get_child(0)
	
	print("UP:", up)
	print("DOWN:", down)
