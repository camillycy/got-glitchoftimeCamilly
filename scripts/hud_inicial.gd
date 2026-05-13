extends CanvasLayer

signal start_game

@onready var fade = $Fade

var game_started := false


func _ready() -> void:
	fade.modulate.a = 0.0


func _input(event):

	if event.is_action_pressed("ui_accept") and !game_started:
		begin_game()


func _on_start_button_pressed() -> void:

	if game_started:
		return

	begin_game()


func begin_game():

	game_started = true

	$StartButton.hide()

	$SoundOn/SoundPlay.play()

	start_game.emit()

	# fade suave
	var tween = create_tween()

	tween.tween_property(
		fade,
		"modulate:a",
		1.0,
		1.5
	)

	await tween.finished

	get_tree().change_scene_to_file(
		"res://scenes/main/intro_scene.tscn"
	)
