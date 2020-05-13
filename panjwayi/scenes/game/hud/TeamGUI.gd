extends Control
class_name TeamGUI

export (String) var team_name
export (Texture) var flag
export (int) var starting_villages
export (Color) var team_color = Color.gray

var button_is_active = false setget set_button_is_active

signal done_button_clicked

onready var num_villages = find_node("Villages")
onready var destroyed_panel: UIPanel = find_node("DestroyedPanel")
onready var reinforcements_panel: UIPanel = find_node("ReinforcementsPanel")
onready var phase_label: Label = find_node("PhaseLabel")
onready var done_button: Button = find_node("DoneButton")

func _ready() -> void:
	find_node("TeamHeading").text = team_name
	find_node("Flag").texture = flag
	find_node("Flag2").texture = flag
	num_villages.text = str(starting_villages)
	color_gui()
	done_button.disabled = !button_is_active
	
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
	
func remove_actor_from_reinforcements(actor: Actor) -> void:
	reinforcements_panel.remove_from_container(actor)
	
func add_actor_to_destroyed(actor) -> void:
#	actor.visible = true  # just in case
	destroyed_panel.add_to_container(actor)
	
func remove_actor_from_destroyed(actor: Actor) -> void:
	actor.visible = true  # just in case
	destroyed_panel.remove_from_container(actor)
	
func move_to_reinforcements(actor: Actor) -> void:
	""" Assumes the actor is already in the destroyed box """
	remove_actor_from_destroyed(actor)
	add_actor_to_reinforcements(actor)
	
func get_reinforcements() -> Array:
	return reinforcements_panel.get_nodes_in_container()
	
func get_destroyed() -> Array:
	return destroyed_panel.get_nodes_in_container()
	
func set_phase(phase_str: String):
	phase_label.text = phase_str

func set_button_is_active(enabled: bool):
	button_is_active = enabled
	done_button.disabled = !enabled
	if enabled:
		done_button.self_modulate = Color.green
	else:
		done_button.self_modulate = Color.white
		
func set_disabled(disabled: bool):
	reinforcements_panel.set_disabled(disabled)
	destroyed_panel.set_disabled(disabled)
	
	
############# SIGNALS ####################

func _on_DoneButton_pressed() -> void:
	self.button_is_active = false
	emit_signal("done_button_clicked")
	
	
