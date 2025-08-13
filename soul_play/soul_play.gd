extends Node2D

func _ready():
	$"Chat Log".modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property($"Chat Log", "modulate:a", 1.0, 0.5)
	await tween.finished
	await get_tree().create_timer(0.1).timeout

	show_dialogue(current_dialogue)

var dialogue_data = {
	"intro": {
		"text": "hi",
		"options": ["santa", "claus"]
	}
}

var current_dialogue = "intro"

func show_dialogue(dialogue_key):
	var data = dialogue_data[dialogue_key]
	$"Chat".text = data.text
	
	$"Two Options".hide()
	$"Three Options".hide()
	
	var options = data.options
	if options.size() == 2:
		$"Two Options".show()
		$"Two Options/Button1".text = options[0]
		$"Two Options/Button2".text = options[1]
	elif options.size() == 3:
		$"Three Options".show()
		$"Three Options/Button1".text = options[0]
		$"Three Options/Button2".text = options[1]
		$"Three Options/Button3".text = options[2]
