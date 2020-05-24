extends TextureButton
class_name PlacementButton

signal selected(actor)

var OFFSET = Vector2(10, 10)

func _ready() -> void:
	connect("button_down", self, "_on_Button_down")
	
func _on_Button_down():
	emit_signal("selected", self)
	$Sound.play()
	
func set_actor(actor: Actor):
	actor.set_name("Actor")
	actor.position = OFFSET
	add_child(actor)
	
func get_actor() -> Actor:
	return get_node("Actor") as Actor
	
func get_texture() -> Texture:
	return get_actor().sprite

func get_team() -> int:
	return get_actor().team
	
func get_actor_type() -> int:
	return get_actor().actor_type
