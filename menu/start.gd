extends Button

func _on_button_pressed():
	$"../ColorRect".modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property($"../ColorRect", "modulate:a", 1.0, 1.5)
	await get_tree().create_timer(0.1).timeout
	tween.tween_callback(_change_scene)

func _change_scene():
	get_tree().change_scene_to_file("res://soul_play.tscn")

func _ready():
	pressed.connect(_on_button_pressed)
