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
		"next": "start_encounter"
	},
	"start_encounter": {
		"text": "",
		"options": ["shoot", "reload", "defend"],
		"responses": ["player_shoot", "player_reload", "player_defend"]
	},
	"player_shoot": {
		"text": "",
		"continue": true,
		"next": "enemy_turn"
	},
	"player_reload": {
		"text": "you reload your weapon.",
		"continue": true, 
		"next": "enemy_turn"
	},
	"player_defend": {
		"text": "you raise your guard.",
		"continue": true,
		"next": "enemy_turn"
	},
	"enemy_turn": {
		"text": "the enemy considers their move...",
		"continue": true,
		"next": "check_result"
	},
	"encounter_intro": {
		"text": "",
		"continue": true,
		"next": "start_encounter"
	}
}

var current_dialogue = "1"

var player_bullets = 0
var enemy_bullets = 0
var is_corrupted = false
var current_enemy_name = ""

var souls_freed = 0
var last_player_action = ""
var last_enemy_action = ""

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

	if current_dialogue == "start_encounter":
		handle_player_action(choice_index)
		return
	
	current_dialogue = next_dialogue
	show_dialogue(current_dialogue)

func handle_player_action(action_index):
	match action_index:
		0: # Shoot
			last_player_action = "shoot"
			if player_bullets > 0:
				player_bullets -= 1
				dialogue_data["player_shoot"]["text"] = "you fire."
			else:
				dialogue_data["player_shoot"]["text"] = "but your weapon is empty."
			current_dialogue = "player_shoot"
		1: # Reload  
			last_player_action = "reload"
			player_bullets += 1
			current_dialogue = "player_reload"
		2: # Defend
			last_player_action = "defend"
			current_dialogue = "player_defend"
	
	show_dialogue(current_dialogue)

func enemy_action():
	# Randomize enemy action
	var enemy_choice = randi() % 3
	match enemy_choice:
		0: # Enemy shoots
			last_enemy_action = "shoot"
			if enemy_bullets > 0:
				enemy_bullets -= 1
				dialogue_data["enemy_turn"]["text"] = current_enemy_name + " fires at you!"
			else:
				dialogue_data["enemy_turn"]["text"] = current_enemy_name + " clicks an empty weapon."
		1: # Enemy reloads
			last_enemy_action = "reload" 
			enemy_bullets += 1
			dialogue_data["enemy_turn"]["text"] = current_enemy_name + " reloads their weapon."
		2: # Enemy defends
			last_enemy_action = "defend"
			dialogue_data["enemy_turn"]["text"] = current_enemy_name + " raises their guard."
	
	current_dialogue = "enemy_turn"
	show_dialogue(current_dialogue)

func check_round_result():
	var player_shot_successfully = (last_player_action == "shoot" and dialogue_data["player_shoot"]["text"] == "you fire.")
	var enemy_shot_successfully = (last_enemy_action == "shoot" and dialogue_data["enemy_turn"]["text"].contains("fires at you!"))
	
	var player_hit = player_shot_successfully and last_enemy_action != "defend"
	var enemy_hit = enemy_shot_successfully and last_player_action != "defend"

	if player_hit and not enemy_hit:
		# Player wins
		souls_freed += 1
		update_souls_display()
		show_win_message()
	elif enemy_hit and not player_hit:
		# Player loses
		show_lose_message()
	else:
		# Continue the round
		current_dialogue = "start_encounter"
		show_dialogue(current_dialogue)

func show_win_message():
	current_dialogue = "win"
	dialogue_data["win"] = {
		"text": "the soul glows softly and fades into the darkness. souls freed: " + str(souls_freed),
		"continue": true,
		"next": "start_encounter"
	}
	show_dialogue(current_dialogue)

func show_lose_message():
	current_dialogue = "lose"
	dialogue_data["lose"] = {
		"text": "you fall unconscious. the sailor's soul drifts away...",
		"continue": true, 
		"next": "start_encounter"
	}
	show_dialogue(current_dialogue)

func update_souls_display():
	# Update your souls counter Label
	$"Souls".text = "souls freed: " + str(souls_freed)

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

func start_new_encounter():
	# 80% normal, 20% corrupted
	is_corrupted = randf() < 0.2
	
	if is_corrupted:
		current_enemy_name = "corrupted soul"
		dialogue_data["encounter_intro"]["text"] = "something approaches...but what is it?"
		dialogue_data["start_encounter"]["text"] = "the corrupted soul flickers at the edge of existence."
	else:
		current_enemy_name = "lost sailor"
		dialogue_data["encounter_intro"]["text"] = "a weary sailor approaches."
		dialogue_data["start_encounter"]["text"] = "the lost sailor watches you silently."
	
	player_bullets = 0
	enemy_bullets = 0
	current_dialogue = "encounter_intro"
	show_dialogue(current_dialogue)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var data = dialogue_data[current_dialogue]
		if data.has("continue") and data.continue:
			var next_dialogue = data.get("next", "1")
			
			if next_dialogue == "start_encounter" and current_dialogue == "11":
				start_new_encounter()
				return
			elif next_dialogue == "enemy_turn":
				# Player action is done, now do enemy action
				enemy_action()
				return
			elif next_dialogue == "check_result":
				# Check the result after enemy turn
				check_round_result()
				return
			elif next_dialogue == "start_encounter" and (current_dialogue == "win" or current_dialogue == "lose"):
				start_new_encounter()
				return

			current_dialogue = next_dialogue
			show_dialogue(current_dialogue)
