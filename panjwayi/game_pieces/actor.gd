"""
An Actor is any Pawn (gameboard piece) that can be placed on a gameboard tile

"""
extends Pawn
class_name Actor

enum ACTOR_TYPES{
	NONE,
	AIR,
	LAV,
	ANA,
	ANP,
	INY, # INF is reserved?
	POP,
	INS,
	IED,
}

export(ACTOR_TYPES) var actor_type = ACTOR_TYPES.NONE

enum TEAM{ NONE, GOA, TALIBAN }
export(TEAM) var team = TEAM.NONE
export(String) var actor_name
export(String) var moves
export(String) var attacks
export(bool) var captures_villages
export(String) var Special
export(ACTOR_TYPES) var flip_side = ACTOR_TYPES.NONE

var is_dragging = false

signal game_piece_dropped(actor, new_location)
signal game_piece_dragged(actor, new_location)
signal game_piece_selected(actor)
signal game_piece_flip_pressed(actor)

func _ready() -> void:
	$Sprite.texture = sprite
	
	if flip_side != ACTOR_TYPES.NONE:
		$FlipButton.visible = true
	else:
		$FlipButton.visible = false
		
	
	
func _input(event):
	if not is_dragging:
		return
	
	if event.is_action_released("ui_select_piece"):
		var new_location = get_global_mouse_position()
		emit_signal("game_piece_dropped", self, new_location)

		
	if is_dragging and event is InputEventMouseMotion:
		var new_location = get_global_mouse_position()
		emit_signal("game_piece_dragged", self, new_location)
		

##### GETTERS AND SETTERS ########

	
	
############ SIGNALS ######################

func _on_Area2D_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("ui_select_piece"):
		get_tree().set_input_as_handled()
		set_selected()

func move(new_location):
	is_dragging = false
	position = new_location
	reset_line()
	reset_ghost()	
	
func potential_move(potential_location):
	update_ghost(potential_location)
	update_line(potential_location)

func update_look_direction(direction):
	$Pivot/Sprite.rotation = direction.angle()

func set_selected():
	emit_signal("game_piece_selected", self)
	$Highlight.visible = true
	is_dragging = true
	
func update_line(target_position):
	$Line2D.visible = true
	$Line2D.set_point_position(1, target_position - position)
	
func reset_line():
	$Line2D.visible = false
	$Line2D.set_point_position(1, Vector2.ZERO)
	
func update_ghost(target_position):
	$Ghost.visible = true
	$Ghost.position = target_position - position
	
func reset_ghost():
	$Highlight.visible = false
	$Ghost.visible = false
	$Ghost.position = Vector2.ZERO


func _on_FlipButton_pressed() -> void:
	# Flip to new actor type
	print("flipping!")
	emit_signal("game_piece_flip_pressed", self)
	
