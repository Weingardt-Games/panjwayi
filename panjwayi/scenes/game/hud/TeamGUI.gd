extends Control
class_name TeamGUI

export (String) var team_name
export (Texture) var flag
export (int) var starting_villages
export (Color) var team_color = Color.gray

onready var num_villages = find_node("Villages")
onready var destroyed_panel: UIPanel = find_node("DestroyedPanel")
onready var reinforcements_panel: UIPanel = find_node("ReinforcementsPanel")

func _ready() -> void:
	find_node("TeamHeading").text = team_name
	find_node("Flag").texture = flag
	find_node("Flag2").texture = flag
	num_villages.text = str(starting_villages)
	color_gui()
	
func color_gui() -> void:
	reinforcements_panel.set_color(team_color)
	destroyed_panel.set_color(team_color)
	var nodes_to_color: Array = find_node("WinConditionContainer").get_children()
	nodes_to_color.append(find_node("TeamHeading"))
	
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
	
