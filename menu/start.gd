extends Button

func _on_button_pressed():
	AudioManager.play_button_sound()
	$"../ColorRect".modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property($"../ColorRect", "modulate:a", 1.0, 1.5)
	await tween.finished
	await get_tree().create_timer(0.1).timeout
	_change_scene()

func _change_scene():
	get_tree().change_scene_to_file("res://soul_play/soul_play.tscn")

func _ready():
	pressed.connect(_on_button_pressed)
