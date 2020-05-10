extends Pawn
class_name Village

export(String) var village_name

onready var label = find_node("Label")

export var GOA_COLOR: Color = Color.blue
export var TALIBAN_COLOR: Color = Color.white

func _ready() -> void:
	$Sprite.texture = sprite
	label.text = village_name
	if team == TEAM.GOA:
		$Sprite.self_modulate = GOA_COLOR
	else:
		$Sprite.self_modulate = TALIBAN_COLOR

func toggle_team():
	if team == TEAM.GOA:
		set_team(TEAM.TALIBAN)
	else:
		set_team(TEAM.GOA)
	
func set_team(new_team):
	team = new_team
	if team == TEAM.GOA:
		$Sprite.self_modulate = GOA_COLOR
	else:
		$Sprite.self_modulate = TALIBAN_COLOR
