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
		"text": "each round, you must shoot, reload, or defend yourself.",
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
	},
		"story_10": {
		"text": "the burden on your shoulders grows lighter.",
		"continue": true,
		"next": "story_10_2"
	},
		"story_10_2": {
		"text": "maybe this was a good idea after all.",
		"continue": true,
		"next": "encounter_intro"
	},
		"story_20": {
		"text": "maybe...it is possible.",
		"continue": true,
		"next": "story_20_2"
	},
		"story_20_2": {
		"text": "maybe you can save them all.",
		"continue": true,
		"next": "encounter_intro"
	},
		"story_30": {
		"text": "you can feel it now.",
		"continue": true,
		"next": "story_30_2"
	},
		"story_30_2": {
		"text": "a warmth returning to our own soul.",
		"continue": true,
		"next": "encounter_intro"
	},
		"story_40": {
		"text": "but it feels eternal.",
		"continue": true,
		"next": "story_40_2"
	},
		"story_40_2": {
		"text": "how long has it been?",
		"continue": true,
		"next": "encounter_intro"
	},
		"story_50": {
		"text": "you sigh. it's over. finally.",
		"continue": true,
		"next": "story_50_2"
	},
		"story_50_2": {
		"text": "but there's always more. time for another island.",
		"continue": true,
		"next": "encounter_intro"
	}
}

var current_dialogue = "1"

var player_bullets = 0
var enemy_bullets = 0
var is_corrupted = false
var current_enemy_name = ""

var total_souls_needed = 50
var last_story_percentage = 0

var souls_freed = 0
var last_player_action = ""
var last_enemy_action = ""

var game_started = false
var story_can_advance = false

var corruption_timer = 0.0
var corruption_duration = 8.0
var pressure_points = []
var pressure_points_needed = 5
var pressure_points_clicked = 0
var corruption_minigame_active = false

func setup_ammo_display():
	if not has_node("Ammo"):
		var ammo_label = Label.new()
		ammo_label.name = "Ammo"
		ammo_label.text = "ammo: 0"
		ammo_label.position = Vector2(20, 100)
		ammo_label.visible = false
		add_child(ammo_label)
	update_ammo_display()

func update_ammo_display():
	$"Ammo".text = "ammo: " + str(player_bullets)

func _ready():
	$"Ammo".visible = false
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
	
	setup_corruption_ui()
	setup_ammo_display()
	
	show_dialogue(current_dialogue)

func setup_corruption_ui():
	if not has_node("CorruptionUI"):
		var corruption_ui = Control.new()
		corruption_ui.name = "CorruptionUI"
		corruption_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(corruption_ui)

func _on_button1_pressed():
	AudioManager.play_button_sound()
	handle_choice(0)

func _on_button2_pressed():
	AudioManager.play_button_sound()
	handle_choice(1)

func _on_button3_pressed():
	AudioManager.play_button_sound()
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
			dialogue_data["player_reload"]["text"] = "you reload your weapon."
			current_dialogue = "player_reload"
		2: # Defend
			last_player_action = "defend"
			current_dialogue = "player_defend"
	
	update_ammo_display()
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
		var old_percentage = int(((souls_freed - 1) / float(total_souls_needed)) * 100)
		var new_percentage = int((souls_freed / float(total_souls_needed)) * 100)
		var milestone_triggered = (new_percentage / 10) > (old_percentage / 10) and new_percentage >= 10
		
		update_souls_display()
		
		if not milestone_triggered:
			show_win_message()
	elif enemy_hit and not player_hit:
		show_lose_message()
	else:
		# Continue the round
		current_dialogue = "start_encounter"
		show_dialogue(current_dialogue)

func show_win_message():
	AudioManager.play_coin_sound()
	current_dialogue = "win"
	dialogue_data["win"] = {
		"text": "the soul glows softly and fades into the darkness.",
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
	var percentage = int((souls_freed * 2 / float(total_souls_needed)) * 100)
	
	$"Souls".text = "souls: " + str(souls_freed)
	$"Story Progress".text = "story: " + str(percentage) + "%"
	
	print("Souls: ", souls_freed, " Percentage: ", percentage)
	
	check_story_milestones()

func check_story_milestones():
	var percentage = int((souls_freed / float(total_souls_needed)) * 100)
	var current_milestone = (percentage / 10) * 10
	
	print("Current milestone: ", current_milestone, " Last: ", last_story_percentage)
	
	if current_milestone >= 10 and current_milestone > last_story_percentage:
		print("Triggering story: story_", current_milestone)
		trigger_story("story_" + str(current_milestone))
		last_story_percentage = current_milestone

func trigger_story(story_key):
	print("Looking for story key: ", story_key)
	if dialogue_data.has(story_key):
		print("Found story, starting sequence")
		$"Ammo".visible = false
		current_dialogue = story_key
		story_can_advance = false
		show_dialogue(current_dialogue)
		await get_tree().create_timer(0.5).timeout
		story_can_advance = true
	else:
		print("Story key not found, starting new encounter")
		start_new_encounter()

func show_dialogue(dialogue_key):
	var data = dialogue_data[dialogue_key]
	print("Showing dialogue: ", dialogue_key, " Text: ", data.text)
	$"Chat".text = data.text
	
	$"Two Options".hide()
	$"Three Options".hide()
	
	if data.has("continue") and data.continue:
		print("Dialogue has continue=true, waiting for click")
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
	# Reset ALL corruption state
	corruption_minigame_active = false
	corruption_timer = 0.0
	pressure_points_clicked = 0
	clear_pressure_points()
	
	# Reset ammo for both player and enemy
	player_bullets = 0
	enemy_bullets = 0
	update_ammo_display()
	
	
	# 80% normal, 20% corrupted * change to 0.2 later
	is_corrupted = randf() < 0.2
	
	if is_corrupted:
		current_enemy_name = "corrupted soul"
		dialogue_data["encounter_intro"]["text"] = "something approaches...but what is it?"
		
		$Sailor/AnimationPlayer.play("corrupt blue sailor")
		$Sailor.visible = true
		$"Ammo".visible = false
		
		start_corruption_minigame()
		
	else:
		current_enemy_name = "lost sailor"
		dialogue_data["encounter_intro"]["text"] = "a weary sailor approaches."
		dialogue_data["start_encounter"]["text"] = "the lost sailor watches you silently."
		
		$Sailor/AnimationPlayer.play("blue sailor")
		$Sailor.visible = true
		$"Ammo".visible = false
		
		current_dialogue = "encounter_intro"
		show_dialogue(current_dialogue)

func start_corruption_minigame():
	corruption_minigame_active = true
	corruption_timer = corruption_duration
	pressure_points_clicked = 0
	
	$"Two Options".hide()
	$"Three Options".hide()
	$"Chat".text = "the corrupted soul is in a frenzy. find their pressure points!"
	
	spawn_pressure_points()

func spawn_pressure_points():
	clear_pressure_points()
	
	var viewport_size = get_viewport().get_visible_rect().size
	var pp_texture = $"Pressure Point".texture_normal
	var btn_scale = Vector2(0.1, 0.1)
	var btn_size = pp_texture.get_size() * btn_scale
	
	var chat_log_pos = $"Chat Log".position
	var min_x = 20
	var max_x = max(min_x, chat_log_pos.x - btn_size.x - 20)
	var min_y = 20
	var max_y = max(min_y, chat_log_pos.y - btn_size.y - 20)
	
	print("Spawn X range: ", min_x, " → ", max_x)
	print("Spawn Y range: ", min_y, " → ", max_y)
	
	for i in range(pressure_points_needed):
		var button = TextureButton.new()
		button.texture_normal = pp_texture
		button.scale = btn_scale
		
		var x_range = max_x - min_x
		var y_range = max_y - min_y
		var x = randf_range(min_x, max_x) if (x_range > 0) else randf_range(0, viewport_size.x - btn_size.x)
		var y = randf_range(min_y, max_y) if (y_range > 0) else randf_range(0, viewport_size.y - btn_size.y)
		
		button.position = Vector2(x, y)
		button.pressed.connect(_on_pressure_point_clicked.bind(button))
		
		$CorruptionUI.add_child(button)
		pressure_points.append(button)

func _on_pressure_point_clicked(button):
	if not corruption_minigame_active:
		return
		
	AudioManager.play_pop_sound()
	pressure_points_clicked += 1
	button.queue_free()
	pressure_points.erase(button)
	
	# Check if all points are clicked
	if pressure_points_clicked >= pressure_points_needed:
		corruption_success()

func corruption_success():
	corruption_minigame_active = false
	clear_pressure_points()
	
	var old_souls = souls_freed
	souls_freed += 1
	update_souls_display()
	
	AudioManager.play_coin_sound()
	$"Chat".text = "the corrupted soul sighs and fades away."
	
	var percentage = int((souls_freed / float(total_souls_needed)) * 100)
	var old_percentage = int((old_souls / float(total_souls_needed)) * 100)
	var milestone_triggered = (percentage / 10) > (old_percentage / 10) and percentage >= 10
	
	if not milestone_triggered:
		await get_tree().create_timer(2.0).timeout
		start_new_encounter()

func corruption_failure():
	corruption_minigame_active = false
	clear_pressure_points()
	
	corruption_timer = 0.0
	pressure_points_clicked = 0
	
	$"Chat".text = "the corrupted soul screams as it it pulled away."
	
	await get_tree().create_timer(2.0).timeout
	start_new_encounter()

func clear_pressure_points():
	for button in pressure_points:
		if is_instance_valid(button):
			button.queue_free()
	pressure_points.clear()

func _process(delta):
	if corruption_minigame_active:
		corruption_timer -= delta
		
		# Update timer display in chat
		var time_left = max(0, int(corruption_timer))
		$"Chat".text = "find the pressure points! time: " + str(time_left) + "s (" + str(pressure_points_clicked) + "/" + str(pressure_points_needed) + ")"
		
		# Check if time is up
		if corruption_timer <= 0:
			corruption_failure()

func _input(event):
	if corruption_minigame_active:
		return
		
	if event is InputEventMouseButton and event.pressed:
		var data = dialogue_data[current_dialogue]
		if data.has("continue") and data.continue:
			if current_dialogue.begins_with("story_") and not story_can_advance:
				print("Story not ready to advance yet")
				return
			
			var next_dialogue = data.get("next", "1")
			print("Current: ", current_dialogue, " Next: ", next_dialogue)
			
			if current_dialogue == "11":
				game_started = true
			
			if next_dialogue == "start_encounter" and current_dialogue == "11":
				start_new_encounter()
				return
			elif current_dialogue == "encounter_intro":
				$"Ammo".visible = true
				current_dialogue = "start_encounter"
				show_dialogue(current_dialogue)
				return
			elif current_dialogue.begins_with("story_") and next_dialogue == "encounter_intro":
				start_new_encounter()
				return
			elif next_dialogue == "encounter_intro" and game_started:
				start_new_encounter()
				return
			elif next_dialogue == "enemy_turn":
				enemy_action()
				return
			elif next_dialogue == "check_result":
				check_round_result()
				return
			elif next_dialogue == "start_encounter" and (current_dialogue == "win" or current_dialogue == "lose"):
				start_new_encounter()
				return

			current_dialogue = next_dialogue
			show_dialogue(current_dialogue)
