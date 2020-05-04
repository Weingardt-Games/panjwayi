extends NinePatchRect
class_name UIPanel

export (String) var panel_heading = "Panel Heading"

export (Color) var panel_color = Color.gray setget set_color

onready var label = find_node("Label")

func _ready() -> void:
	label.text = panel_heading
	# self to call setter
	self.set_color(panel_color)
	
func set_color(color: Color):
	panel_color = color
	label.self_modulate = color
	self_modulate = color
