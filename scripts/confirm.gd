extends Control

@onready var player1_word_label = $ConfirmCanvasLayer/BG_Box/MarginContainer/VBoxContainer/P1_box/MarginContainer/VBoxContainer/Player1Word
@onready var player1_status_icon = $ConfirmCanvasLayer/BG_Box/MarginContainer/VBoxContainer/P1_box/Player1Status
@onready var player2_word_label = $ConfirmCanvasLayer/BG_Box/MarginContainer/VBoxContainer/P2_box/MarginContainer/VBoxContainer/Player2Word
@onready var player2_status_icon = $ConfirmCanvasLayer/BG_Box/MarginContainer/VBoxContainer/P2_box/Player2Status
@onready var category_text = $ConfirmCanvasLayer/BG_Box/MarginContainer/VBoxContainer/Category_box/Category
@onready var japanese_text = $ConfirmCanvasLayer/BG_Box/MarginContainer/VBoxContainer/Category_box/Japanese

var board_scene  # Reference to the board
var fireball_moves = []  # Stores fireball moves

func setup(category: String, japanese: String, p1_word: String, p1_valid: bool, p2_word: String, p2_valid: bool, board_ref, moves):
	player1_word_label.text = p1_word
	player2_word_label.text = p2_word
	category_text.text = category
	japanese_text.text = japanese
	
	# Load icons based on validity
	var check_icon = preload("res://assets/sprites/check.png")  # Add a checkmark image
	var x_icon = preload("res://assets/sprites/x.png")  # Add an X image
	
	player1_status_icon.texture = check_icon if p1_valid else x_icon
	player2_status_icon.texture = check_icon if p2_valid else x_icon
	
	board_scene = board_ref
	fireball_moves = moves


func _on_done_button_pressed() -> void:
	close()


func close():
	queue_free()  # Close confirmation screen
	board_scene.process_queued_fireballs()  # Move fireballs
