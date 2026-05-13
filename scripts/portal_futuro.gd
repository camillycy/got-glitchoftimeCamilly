extends Area2D

@onready var manager = get_tree().get_first_node_in_group("phase_manager")

func _on_body_entered(body):

	print(body.name)

	if manager == null:
		print("PHASE MANAGER NÃO ENCONTRADO")
		return

	if "Cientista" in body.name:
		manager.cientista_chegou()


func _on_body_exited(body):

	if manager == null:
		return

	if "Cientista" in body.name:
		manager.cientista_saiu()
