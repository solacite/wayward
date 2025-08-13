extends Node2D

func _ready():
	$"Chat Log".modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property($"Chat Log", "modulate:a", 1.0, 0.5)
	await tween.finished
	await get_tree().create_timer(0.1).timeout
