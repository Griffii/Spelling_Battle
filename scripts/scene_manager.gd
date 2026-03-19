extends Node

signal scene_changed(scene_path: String, scene_instance: Node)

var scene_root: Node = null
var current_scene: Node = null
var current_scene_path: String = ""

func setup(p_scene_root: Node) -> void:
	scene_root = p_scene_root



func change_scene(scene_path: String) -> void:
	if scene_root == null:
		push_error("SceneManager: scene_root has not been set. Call SceneManager.setup() from game.gd first.")
		return
	
	call_deferred("_do_change_scene", scene_path)


func _do_change_scene(scene_path: String) -> void:
	# Remove old scene.
	if current_scene != null:
		current_scene.queue_free()
		current_scene = null
		current_scene_path = ""
	
	# Load and instance new scene.
	var packed: PackedScene = load(scene_path)
	if packed == null:
		push_error("SceneManager: Failed to load scene: %s" % scene_path)
		return
	
	var new_scene := packed.instantiate()
	scene_root.add_child(new_scene)
	
	current_scene = new_scene
	current_scene_path = scene_path
	
	scene_changed.emit(scene_path, new_scene)


func reload_current_scene() -> void:
	if current_scene_path != "":
		change_scene(current_scene_path)


func get_current_scene() -> Node:
	return current_scene
