extends Control

export (String) var team_name
export (Texture) var flag
export (int) var starting_villages

onready var num_villages = find_node("Villages")

func _ready() -> void:
	find_node("TeamHeading").text = team_name
	find_node("Flag").texture = flag
	find_node("Flag2").texture = flag
	num_villages.text = str(starting_villages)
