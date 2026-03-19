extends Control

@onready var duel_button = $MarginContainer/The_Board/Labels/DualButton
@onready var fireball_container = $MarginContainer/FireballContainer  # A Node2D to hold fireballs
@onready var duel_container = $DualContainer  # Empty Control node for duel scene
@onready var letter_container = $MarginContainer/LettersContainer
@onready var player1_health_label = $MarginContainer/The_Board/Labels/Player1Box/HBoxContainer/Player1Health
@onready var player2_health_label = $MarginContainer/The_Board/Labels/Player2Box/HBoxContainer/Player2Health

@onready var intro_chime: AudioStreamPlayer2D = $audio_intro
@onready var fire_move: AudioStreamPlayer2D = $fire_move
@onready var fire_explosion: AudioStreamPlayer2D = $fire_explosion


const FIREBALL_SCENE = preload("res://scenes/fireball.tscn")
const DUEL_SCENE = preload("res://scenes/duel.tscn")
const GAME_OVER_SCENE = preload("res://scenes/game_over.tscn")

var player_health = {1: 3, 2: 3}  # Player health tracking
const TOP_Y_LIMIT = 210    # Adjust based on board size
const BOTTOM_Y_LIMIT = 840  # Adjust based on board size
var SIZE_OF_SQUARES = 80

var available_categories = {}  # Categories that can still be chosen
var used_categories = {}  # Categories that have already been used
var fireball_queue = [] # Stores fireballs to move after duel closes

func _ready():
	duel_button.pressed.connect(open_duel)
	load_categories()
	intro_chime.play()

# Automatically check fireball positions every frame
func _process(_delta):
	pass


func load_categories():
	var file = FileAccess.open("res://data/categories.json", FileAccess.READ)
	if file:
		##print("File found.")
		var json_data = JSON.parse_string(file.get_as_text())
		if json_data:
			available_categories = json_data  # Start with all categories

# Pick a category and ensure it hasn't been used
func pick_random_category():
	if available_categories.size() == 0:
		if used_categories.size() == 0:
			push_error("No categories available and no used categories to reset!")
			return ["", ""]  # Return empty values to prevent crashes
		
		# Reset when all categories are used
		available_categories = used_categories.duplicate()
		used_categories.clear()
	
	# Get a random category safely
	var keys = available_categories.keys()
	if keys.size() == 0:
		push_error("Error: No categories available to choose from!")
		return ["", ""]  # Prevent division by zero
	
	var selected_category_key = keys[randi() % keys.size()]
	var selected_category_text = available_categories[selected_category_key]
	##print("Category Key: ", selected_category_key)
	##print("Category Text: ", selected_category_text)
	var category_question = selected_category_text[0]
	var category_japanese = selected_category_text[1]
	
	# Move selected category from available to used
	used_categories[selected_category_key] = selected_category_text
	available_categories.erase(selected_category_key)
	
	return [selected_category_key, category_question, category_japanese]

# Spawn a fireball at the specified letter's position
func spawn_fireball(letter: String):
	var letter_label = get_node_or_null("MarginContainer/LettersContainer/" + letter)
	
	if letter_label:
		var fireball = FIREBALL_SCENE.instantiate()
		
		# Get the label's center position
		var label_center = letter_label.global_position + (letter_label.size / 2)
		
		# Set fireball position to the exact center of the label
		fireball.global_position = label_center
		
		
		fireball.name = letter + "_Fireball"  # Unique name for tracking
		fireball_container.add_child(fireball)
		##print("Spawned fireball at ", letter, " position: ", fireball.position)
		return fireball
	else:
		push_error("Letter '" + letter + "' not found!")
		return null

# Function to open the duel scene
func open_duel():
	for child in duel_container.get_children():
		child.queue_free()  # Remove any existing duel instance
	
	var duel_instance = DUEL_SCENE.instantiate()
	duel_instance.board_scene = self  # Pass board reference
	duel_container.add_child(duel_instance)

# Function to check if fireballs reach the end
func check_fireball_positions():
	for fireball in fireball_container.get_children():
		if fireball.position.y <= TOP_Y_LIMIT && fireball.is_valid:
			damage_player(1)  # Player 1 takes damage
			fireball.explode()  # Explode and despawn fireball
		elif fireball.position.y >= BOTTOM_Y_LIMIT  && fireball.is_valid:
			damage_player(2)  # Player 2 takes damage
			fireball.explode()  # Explode and despawn fireball

# Function to decrease player health and update UI
func damage_player(player: int):
	player_health[player] -= 1
	if player == 1:
		player1_health_label.text = str(player_health[player])
	else:
		player2_health_label.text = str(player_health[player])
	
	
	fire_explosion.play()
	
	##print("Player", player, "took damage! Health:", player_health[player])
	
	# Check if anyone died
	check_gameover()

# Called when the duel scene is dismissed
func process_queued_fireballs():
	##print("Process queued fireballs called...")
	if fireball_queue.is_empty():
		return
	
	for move in fireball_queue:
		await move_fireball_one_by_one(move.letter, move.player, move.spaces)
	
	fireball_queue.clear()  # Clear queue after all movements finish

# Move fireballs one by one
func move_fireball_one_by_one(letter: String, player_turn: int, spaces: int):
	##print("Move fireball called for ", letter)
	var fireball = fireball_container.get_node_or_null(letter + "_Fireball")
	
	# Spawn fireball if it doesn't exist
	if fireball == null:
		##print("Fireball not found, spawning...")
		fireball = spawn_fireball(letter)
		if fireball == null:
			return  # Letter not found, abort move
	else:
		# Play fire moving sound if not spawning fireball
		fire_move.play()
		##print("Fireball found, moving ", letter)
	
	var move_distance = spaces * SIZE_OF_SQUARES
	var direction = 1 if player_turn == 1 else -1
	var target_position = fireball.global_position.y + (move_distance * direction)
	
	if target_position > BOTTOM_Y_LIMIT:
		target_position = BOTTOM_Y_LIMIT
	elif target_position < TOP_Y_LIMIT:
		target_position = TOP_Y_LIMIT
	
	# Animate fireball movement
	var tween = get_tree().create_tween()
	tween.tween_property(fireball, "global_position:y", target_position, 0.5 * spaces)
	await tween.finished
	
	# Check after moving rather than every tick
	check_fireball_positions()

# Check if any players have zero health
func get_winner():
	var winner = []
	
	if player_health[1] <= 0:
		winner.append(2)
	if player_health[2] <= 0:
		winner.append(1)
	
	return winner


# Check if game should end
func check_gameover():
	if player_health[1] <= 0 || player_health[2] <= 0:
		# Slight pause to let explosion animation finish
		await get_tree().create_timer(2.0).timeout  # Pauses for 2 seconds
		gameover()


# Function to end the game / Pull up end game screen
func gameover():
	var gameover_instance = GAME_OVER_SCENE.instantiate()
	add_child(gameover_instance)
	
	# Check the winners and pass the array to the new game ocer scene
	gameover_instance.setup(get_winner())
