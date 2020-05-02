extends Control

export (String) var team_name
export (Texture) var flag
export (int) var starting_villages
export (Color) var team_color = Color.gray

onready var num_villages = find_node("Villages")

func _ready() -> void:
	find_node("TeamHeading").text = team_name
	find_node("Flag").texture = flag
	find_node("Flag2").texture = flag
	num_villages.text = str(starting_villages)
	color_gui()
	
func color_gui():
	var destroyed_panel = find_node("DestroyedPanel")
	var reinforcements_panel = find_node("ReinforcementsPanel")
	var nodes_to_color = [
		destroyed_panel,
		destroyed_panel.find_node("Label"),
		reinforcements_panel,
		reinforcements_panel.find_node("Label")
	]
	nodes_to_color += find_node("WinConditionContainer").get_children()
	
	for node in nodes_to_color:
		node.self_modulate = team_color
