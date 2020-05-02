extends Control

var scene_change_to
onready var default_button = find_node("CreateGameButton")

func _ready() -> void:
	default_button.grab_focus()
	for button in find_node("Buttons").get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load, button.uri_to_open])

func _on_Button_pressed(scene_to_load: PackedScene, uri_to_open: String):
	if scene_to_load:
		scene_change_to = scene_to_load 
		$FadeIn.show()
		$FadeIn.fade_in()
	elif uri_to_open:
#		var default_cursor = default_button.get_default_cursor_shape()
#		default_button.set_default_cursor_shape(CURSOR_MOVE)
		var error = OS.shell_open(uri_to_open)
		print(error)
		yield(get_tree().create_timer(0.5), "timeout")
		default_button.grab_focus()
#		default_button.set_default_cursor_shape(default_cursor)
		

func _on_FadeIn_fade_finished() -> void:
		get_tree().change_scene_to(scene_change_to)
