extends Node2D

# options & responses: ["1" "2"]

var dialogue_data = {
	"1": {
		"text": "wayward.",
		"continue": true,
		"next": "2"
	},
	"2": {
		"text": "rebellious. defiant. stubborn.",
		"continue": true,
		"next": "3"
	},
	"3": {
		"text": "such are the souls that wander these sands.",
		"continue": true,
		"next": "4"
	},
	"4": {
		"text": "you have been tasked with bringing them home.",
		"continue": true,
		"next": "5"
	},
	"5": {
		"text": "you will play a small game with them to make them content.",
		"continue": true,
		"next": "6"
	},
	"6": {
		"text": "each round, you can choose to shoot, reload, or defend yourself.",
		"continue": true,
		"next": "7"
	},
	"7": {
		"text": "the goal is to shoot your opponent without getting shot.",
		"continue": true,
		"next": "8"
	},
	"8": {
		"text": "sometimes, you may encounter corrupted souls.",
		"continue": true,
		"next": "9"
	},
	"9": {
		"text": "they have been lost for too long.",
		"continue": true,
		"next": "10"
	},
	"10": {
		"text": "you must appease them.",
		"continue": true,
		"next": "11"
	},
	"11": {
		"text": "good luck...",
		"continue": true,
		"next": "12"
	},
}

var current_dialogue = "1"

func _ready():
	$"Two Options/Button1".pressed.connect(_on_button1_pressed)
	$"Two Options/Button2".pressed.connect(_on_button2_pressed)
	$"Three Options/Button1".pressed.connect(_on_button1_pressed)
	$"Three Options/Button2".pressed.connect(_on_button2_pressed)
	$"Three Options/Button3".pressed.connect(_on_button3_pressed)

	$"Chat Log".modulate.a = 0.0
	$"Two Options".modulate.a = 0.0
	$"Three Options".modulate.a = 0.0

	var tween = create_tween()
	tween.parallel().tween_property($"Chat Log", "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property($"Two Options", "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property($"Three Options", "modulate:a", 1.0, 0.5)
	await tween.finished
	await get_tree().create_timer(0.1).timeout
	show_dialogue(current_dialogue)

func _on_button1_pressed():
	handle_choice(0)

func _on_button2_pressed():
	handle_choice(1)

func _on_button3_pressed():
	handle_choice(2)

func handle_choice(choice_index):
	var data = dialogue_data[current_dialogue]
	var next_dialogue = data.responses[choice_index]
	current_dialogue = next_dialogue
	show_dialogue(current_dialogue)

func show_dialogue(dialogue_key):
	var data = dialogue_data[dialogue_key]
	$"Chat".text = data.text
	
	$"Two Options".hide()
	$"Three Options".hide()
	
	if data.has("continue") and data.continue:
		return
	else:
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

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var data = dialogue_data[current_dialogue]
		if data.has("continue") and data.continue:
			var next_dialogue = data.get("next", "1")
			current_dialogue = next_dialogue
			show_dialogue(current_dialogue)
