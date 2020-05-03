extends NinePatchRect

export (String) var panel_heading = "Panel Heading"

func _ready() -> void:
	var label = find_node("Label")
	label.text = panel_heading
