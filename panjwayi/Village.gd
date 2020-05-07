extends Pawn

export(String) var village_name

onready var label = find_node("Label")

func _ready() -> void:
	$Sprite.texture = sprite
	label.text = village_name
	if team == TEAM.GOA:
		$Sprite.self_modulate = Color.red
