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
	var destroyed_panel: UIPanel = find_node("DestroyedPanel")
	var reinforcements_panel: UIPanel = find_node("ReinforcementsPanel")
	reinforcements_panel.set_color(team_color)
	destroyed_panel.set_color(team_color)
	var nodes_to_color: Array = find_node("WinConditionContainer").get_children()
	nodes_to_color.append(find_node("TeamHeading"))
	
	for node in nodes_to_color:
		node.self_modulate = team_color
