extends Control

@onready var category_label = $DuelCanvas/MarginContainer/VBoxContainer/MarginContainer/CategoryLabel
@onready var player_input = $DuelCanvas/MarginContainer/VBoxContainer/PlayerInput
@onready var confirm_button = $DuelCanvas/MarginContainer/ConfirmButton
@onready var done_button = $DuelCanvas/MarginContainer/VBoxContainer/DoneButton
@onready var timer = $DuelCanvas/Timer
@onready var timer_label = $DuelCanvas/Timer/TimerLabel

var board_scene  # Reference to board scene
var current_player = 1  # Track player turn (1 or 2)
var categories = {}  # Stores loaded categories
var selected_category_key = ""
var selected_category_text = ""
var selected_category_japanese = ""
var player1_word = ""
var player1_valid = false
var player2_word = ""
var player2_valid = false

var fireball_moves = [] # Stores fireball that need to move

func _ready():
	if board_scene:
		var category_data = board_scene.pick_random_category()
		selected_category_key = category_data[0]
		selected_category_text = category_data[1]
		selected_category_japanese = category_data[2]
		confirm_button.text = "Ready Player " + str(current_player) + "?"
	
	confirm_button.pressed.connect(start_round)
	done_button.pressed.connect(stop_timer_and_done)
	timer.timeout.connect(done)
	
	category_label.hide() #Hide the category label upon load
	player_input.hide()
	done_button.hide()

func _process(_delta):
	if Input.is_action_just_pressed("enter"):
		stop_timer_and_done()


func start_round():
	confirm_button.hide()
	category_label.text = selected_category_text
	category_label.show() # Reveal the category text
	player_input.show()
	done_button.show()
	timer.start(30)
	update_timer_display()

func update_timer_display():
	timer_label.text = str(int(timer.time_left))  # Show remaining time
	await get_tree().create_timer(1).timeout  # Update every second
	if timer.time_left > 0:
		update_timer_display()

func stop_timer_and_done():
	timer.stop()
	done()

func done():
	var og_word = player_input.text
	var word = og_word.strip_edges().to_lower()
	
	if current_player == 1:
		player1_word = og_word
	else:
		player2_word = og_word
	
	if word.is_empty():
		##print("Word was empty for Player " + str(current_player))
		return
	
	if validate_word(word):
		queue_fireballs(word)
	
	# Switch turn AFTER processing the word
	if current_player == 1:
		current_player = 2
		reset_for_player_2()  # Now Player 2 gets to enter their word
	else:
		# Player 2 has finished, now we open confirmation screen
		open_confirmation_screen(selected_category_text, selected_category_japanese, player1_word, player1_valid, player2_word, player2_valid)
		queue_free()  # Close duel scene after both players answer


# Validate if word exists in the correct category JSON file
func validate_word(word: String) -> bool:
	##print("Validating: ", word)
	var file_path = "res://data/" + selected_category_key + ".json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var json_text = file.get_as_text()
		var json_data = JSON.parse_string(json_text)
		
		if json_data is Array:
			if word in json_data:
				if current_player == 1:
					player1_valid = true
				else: 
					player2_valid = true
				return true
			else:
				##print(word + " is not valid.")
				return false
	
	push_error("Invalid JSON format: Expected an array.")
	return false  # Word not found or JSON issue


# Process fireballs if the word is valid
func queue_fireballs(word: String):
	var consonants = "bcdfghjklmnpqrstvwxyz"
	var consonant_counts = {}
	
	for letter in word:
		if letter in consonants:
			consonant_counts[letter] = consonant_counts.get(letter, 0) + 1
	
	if board_scene:
		for letter in consonant_counts.keys():
			fireball_moves.append({"letter": letter, "player": current_player, "spaces": consonant_counts[letter]})
	
	# Notify the board scene that fireballs are ready to move after duel closes
	board_scene.fireball_queue = fireball_moves

# Reset scene for Player 2 to answer
func reset_for_player_2():
	category_label.hide() # Hide category text
	player_input.hide() # Hide input box
	player_input.clear()
	done_button.hide() # Hide the done button
	confirm_button.text = "Ready Player 2?"
	confirm_button.show()
	timer.stop()

func _exit_tree():
	pass



# Show confirm screen before moving fireballs
func open_confirmation_screen(category, japanese, p1_word, p1_valid, p2_word, p2_valid):
	var confirm_scene = preload("res://scenes/confirm.tscn").instantiate()
	get_tree().current_scene.add_child(confirm_scene)
	
	confirm_scene.setup(category, japanese, p1_word, p1_valid, p2_word, p2_valid, board_scene, fireball_moves)
