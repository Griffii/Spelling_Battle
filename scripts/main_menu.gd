extends Control



func become_host():
	MultiplayerManager.become_host()
	
	SceneManager.change_scene("res://scenes/lobby.tscn")


func join_game():
	MultiplayerManager.join_game()
	
	SceneManager.change_scene("res://scenes/lobby.tscn")
