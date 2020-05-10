extends Pawn
class_name Village

export(String) var village_name

onready var label = find_node("Label")

func _ready() -> void:
	$Sprite.texture = sprite
	label.text = village_name
	if team == TEAM.GOA:
		$Sprite.self_modulate = Color.red

func toggle_team():
	if team == TEAM.GOA:
		_set_team(TEAM.TALIBAN)
	else:
		_set_team(TEAM.GOA)
	
func _set_team(new_team):
	team = new_team
	if team == TEAM.GOA:
		$Sprite.self_modulate = Color.red
	else:
		$Sprite.self_modulte = Color.white
