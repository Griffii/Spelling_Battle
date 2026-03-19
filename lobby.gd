extends Control

@onready var host_container = %HostUI
@onready var join_container = %JoinUI

func _ready():
	update_lobby_ui()

func update_lobby_ui():
	if multiplayer.multiplayer_peer == null:
		# No active network peer yet
		host_container.visible = false
		join_container.visible = false
		return

	if multiplayer.is_server():
		host_container.visible = true
		join_container.visible = false
	else:
		host_container.visible = false
		join_container.visible = true
