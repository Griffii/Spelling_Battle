extends Control

@onready var player1win = $GameOverCanvas/NinePatchRect/VBoxContainer/LabelContainer/Player1
@onready var player2win = $GameOverCanvas/NinePatchRect/VBoxContainer/LabelContainer/Player2
@onready var tie = $GameOverCanvas/NinePatchRect/VBoxContainer/LabelContainer/Tie
@onready var play_again_button: Button = $GameOverCanvas/NinePatchRect/VBoxContainer/PlayAgainButton


func _ready():
	pass


func setup(winners: Array):
	if winners.is_empty():
		##print("ERROR: No winner array passed to game over scene!")
		return
	
	if winners.has(1) && winners.has(2):
		tie.show()
	elif winners.has(1):
		player1win.show()
	elif winners.has(2):
		player2win.show()


func restart_game():
	var root_scene = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(root_scene)


func _on_play_again_button_pressed() -> void:
	restart_game()
