extends Control
class_name TeamGUI

export (String) var team_name
export (Texture) var flag
export (int) var starting_villages
export (Color) var team_color = Color.gray

#var button_is_active = false setget set_button_is_active

signal done_button_clicked
signal reinforcements_button_pressed
signal destroyed_button_pressed

onready var num_villages = find_node("Villages")
onready var destroyed_panel: UIPanel = find_node("DestroyedPanel")
onready var reinforcements_panel: UIPanel = find_node("ReinforcementsPanel")
onready var phase_label: Label = find_node("PhaseLabel")
onready var team_heading: Label = find_node("TeamHeading")
onready var flag1: TextureRect = find_node("Flag")
onready var flag2: TextureRect = find_node("Flag2")

func _ready() -> void:
	team_heading.text = team_name
	flag1.texture = flag
	flag2.texture = flag
	num_villages.text = str(starting_villages)
	reinforcements_panel.set_button_text("Action")
	destroyed_panel.set_button_text("Move")
	color_gui()
	
func color_gui() -> void:
	reinforcements_panel.set_color(team_color)
	destroyed_panel.set_color(team_color)
	var nodes_to_color: Array = find_node("WinConditionContainer").get_children()
	nodes_to_color.append(find_node("TeamHeading"))
	nodes_to_color += find_node("PhaseContainer").get_children()
	
	for node in nodes_to_color:
		node.self_modulate = team_color

func add_actor_to_reinforcements(actor) -> void:
	actor.visible = true  # just in case
	reinforcements_panel.add_to_container(actor)
	
func remove_actor_from_reinforcements(actor) -> void:
	reinforcements_panel.remove_from_container(actor)
	
func add_actor_to_destroyed(actor) -> void:
#	actor.visible = true  # just in case
	destroyed_panel.add_to_container(actor)
	
func remove_actor_from_destroyed(actor) -> void:
	actor.visible = true  # just in case
	destroyed_panel.remove_from_container(actor)
	
func move_to_reinforcements(actor) -> void:
	""" Assumes the actor is already in the destroyed box """
	remove_actor_from_destroyed(actor)
	add_actor_to_reinforcements(actor)
	
func get_reinforcements() -> Array:
	return reinforcements_panel.get_nodes_in_container()
	
func get_destroyed(only_reinforceable=true) -> Array:
	var destroyed: Array = destroyed_panel.get_nodes_in_container()
	if only_reinforceable:
		for button in destroyed:
	
			if button.get_actor().destroyed_is_permanent:
				destroyed.erase(button)
	return destroyed
	
func set_phase(phase_str: String):
	phase_label.text = phase_str

#func set_button_is_active(enabled: bool):
#	button_is_active = enabled
#	done_button.disabled = !enabled
#	if enabled:
#		done_button.self_modulate = Color.green
#	else:
#		done_button.self_modulate = Color.white
		
func set_disabled(disabled: bool):
	reinforcements_panel.set_disabled(disabled)
	destroyed_panel.set_disabled(true)

	flag1.visible = !disabled
	flag2.visible = !disabled
	

func enable_reinforcements_placement(enable: bool):
	reinforcements_panel.set_highlighted(enable)
	
############# SIGNALS ####################

func _on_DoneButton_pressed() -> void:
	self.button_is_active = false
	emit_signal("done_button_clicked")

func _on_ReinforcementsPanel_action_button_pressed() -> void:
	emit_signal("reinforcements_button_pressed")
	
func _on_DestroyedPanel_action_button_pressed() -> void:
	emit_signal("destroyed_button_pressed")
