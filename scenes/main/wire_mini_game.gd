extends CanvasLayer

signal puzzle_completed

var selected_node = null
var correct_connections = [
	["Button", "Button2"],
	["Button3", "Button4"],
	["Button5", "Button6"]
]

var current_connections = []

func _ready():
	visible = false

	for button in $PuzzlePanel.get_children():
		button.pressed.connect(_on_node_pressed.bind(button.name))


func _on_node_pressed(node_name):
	if selected_node == null:
		selected_node = node_name
		return

	if selected_node != node_name:
		current_connections.append([selected_node, node_name])

	selected_node = null
	check_solution()


func check_solution():
	var correct = 0

	for c in current_connections:
		if c in correct_connections or [c[1], c[0]] in correct_connections:
			correct += 1

	if correct >= correct_connections.size():
		puzzle_complete()


func puzzle_complete():
	visible = false
	emit_signal("puzzle_completed")
