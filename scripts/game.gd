extends Control

@onready var scene_root: Node = $SceneRoot
@onready var background_root: CanvasLayer = $BG_Canvas

@onready var how_to_popup = $HelpCanvasLayer/HowToContainer
@onready var how_to_blocker = $HelpCanvasLayer/HowToBlocker

func _ready() -> void:
	# Hide overlay menus
	how_to_popup.visible = false
	how_to_blocker.visible = false
	
	# Register the persistent roots with the SceneManager.
	SceneManager.setup(scene_root)
	
	# Load the first visible scene.
	SceneManager.change_scene("res://scenes/main_menu.tscn")



func _input(event):
	if event.is_action_pressed("ui_toggle_fullscreen"):
		toggle_fullscreen()

func toggle_fullscreen():
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1280, 720))  
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)



func _on_help_button_pressed() -> void:
	how_to_popup.visible = !how_to_popup.visible
	how_to_blocker.visible = !how_to_blocker.visible


func _on_fullscreen_button_pressed() -> void:
	toggle_fullscreen()
