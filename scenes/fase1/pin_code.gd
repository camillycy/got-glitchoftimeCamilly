extends Node2D

@export var allow_crossed_wires = true
@export var only_cardinals = false

signal puzzle_completed

const Circle = preload("res://scenes/fase1/circle.gd")

var circles: Array[Circle] = []
var correct_sequence = Line2D.new()
var is_correct = false
var correct_color = null

var show_hint = false

var spacing = 150
var radius = 36
var side_offset = 100
var currently_selected = null
var default_color = Color.GREEN

var main_line = Line2D.new()

var solved_color = Color.PURPLE


func _ready() -> void:

	if not Global.has_setup:
		Global.allow_crossed_wires = allow_crossed_wires
		Global.only_cardinals = only_cardinals
		Global.has_setup = true

	add_child(main_line)

	# cria os círculos
	for y in range(3):
		for x in range(3):
			circles.append(
				Circle.new(
					Vector2(
						x * spacing + side_offset,
						y * spacing + side_offset
					),
					radius,
					default_color
				)
			)

	# sequência correta do puzzle
	for i in [0, 1, 4, 2, 5, 8, 7, 3, 6]:
		correct_sequence.add_point(circles[i].pos)

	queue_redraw()
	print("PIN CODE RODANDO")
	

func _process(_delta: float) -> void:
	allow_crossed_wires = Global.allow_crossed_wires
	only_cardinals = Global.only_cardinals


func is_connection_valid(start: Vector2, end: Vector2) -> bool:

	if not allow_crossed_wires:
		for i in range(main_line.points.size() - 1):

			if Geometry2D.segment_intersects_segment(
				main_line.get_point_position(i),
				main_line.get_point_position(i + 1),
				start,
				end
			) != null and main_line.get_point_position(i + 1) != start:
				return false

	if only_cardinals and not (
		start.x == end.x or start.y == end.y
	):
		return false

	for circle in circles:

		if circle.pos == start or circle.pos == end:
			continue

		if main_line.points.has(end):
			return false

		if Geometry2D.segment_intersects_circle(
			start,
			end,
			circle.pos,
			circle.radius
		) >= 0:
			return false

	return true


func _input(_event: InputEvent) -> void:

	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()
		show_hint = !show_hint
		queue_redraw()
	
	if Input.is_action_pressed("select"):

		for circle in circles:

			if Geometry2D.is_point_in_circle(
				get_local_mouse_position(),
				circle.pos,
				radius
			):

				if currently_selected != null:
					currently_selected.color = default_color

				if currently_selected == null or is_connection_valid(
					currently_selected.pos,
					circle.pos
				):

					main_line.add_point(circle.pos)
					currently_selected = circle
					circle.color = Color.BLACK

					queue_redraw()


func blink_color():

	for i in range(10):
		correct_color = solved_color
		queue_redraw()

		await get_tree().create_timer(0.2).timeout

		correct_color = null
		queue_redraw()

		await get_tree().create_timer(0.2).timeout


func _draw():

	# DEBUG VISUAL
	draw_rect(
		Rect2(Vector2.ZERO, Vector2(600, 600)),
		Color.RED
	)

	# verifica solução
	if not is_correct and main_line.points == correct_sequence.points:

		is_correct = true

		print("Puzzle resolvido")

		puzzle_completed.emit()

		blink_color()

	# desenha círculos
	for circle in circles:

		if correct_color == null:
			draw_circle(
				circle.pos,
				circle.radius,
				circle.color
			)
		else:
			draw_circle(
				circle.pos,
				circle.radius,
				correct_color
			)

	# desenha linhas
	if main_line.points.size() > 1:

		for i in range(main_line.points.size() - 1):

			draw_line(
				main_line.points[i],
				main_line.points[i + 1],
				Color.BLACK,
				8
			)
		if show_hint:

			var texture = load(
				"res://scenes/fase1/answer_paper.png"
			)

			draw_texture(
				texture,
				Vector2(620, 50)
			)
