"""
An Actor is any Pawn (gameboard piece) that can be placed on a gameboard tile

"""
extends Pawn
class_name Actor

enum ACTOR_TYPES {
	NONE,
	AIR,
	LAV,
	ANA,
	ANP,
	INY, # INF is reserved?
	POP,
	INS,
	IED,
	ALL,
}

enum MOVEMENT_TYPES {
	STATIONARY,
	KING,
	KING_TWICE, 
	QUEEN,
	ROOK	
}

export(ACTOR_TYPES) var actor_type = ACTOR_TYPES.NONE

enum TEAM{ NONE, GOA, TALIBAN }
export(TEAM) var team = TEAM.NONE
export(String) var actor_name
export(String) var moves
export(MOVEMENT_TYPES) var movement_type = MOVEMENT_TYPES.KING
export(String) var attacks
export(Array, ACTOR_TYPES) var attackable_units = [ACTOR_TYPES.NONE]
export(bool) var captures_villages
export(String) var Special
export(ACTOR_TYPES) var flip_side = ACTOR_TYPES.NONE

var is_dragging = false
var is_enabled = true setget _set_is_enabled
var is_selected = false

signal game_piece_dropped(actor, new_location)
signal game_piece_dragged(actor, new_location)
signal game_piece_selected(actor)
signal game_piece_flip_pressed(actor)
signal game_piece_movement_cancelled()

func _ready() -> void:
	$Sprite.texture = sprite
	$Ghost.texture = sprite
	
	if flip_side != ACTOR_TYPES.NONE:
		$FlipButton.visible = true
	else:
		$FlipButton.visible = false
		
	
func _input(event):
	# ALL input events
	
	# There is no _is_action_just_pressed here because of the echo thing...
	#https://godotengine.org/qa/45910/how-to-get-key_a-or-any-other-key-just-pressed
	var just_pressed = event.is_pressed() and not event.is_echo()
	
	if is_selected:
		if event.is_action_released("ui_select"): # or (event.is_action_pressed("ui_select") and just_pressed): 
			# place the piece if left-click or equivalent is:
			# released (if they are holding the button)
			# just pressed (if they were not holding the button)
			print("Released: ", actor_name)
			emit_signal("game_piece_dropped", self, get_global_mouse_position())
			
		if event is InputEventMouseMotion:
#			print("Dragged: ", actor_name)
			emit_signal("game_piece_dragged", self, get_global_mouse_position())
			
		if event.is_action_pressed("ui_cancel"):
			cancel_move()
			print("Cancelled: ", actor_name)
			emit_signal("game_piece_movement_cancelled")

##### GETTERS AND SETTERS ########

	
	
############ SIGNALS ######################

func _on_Area2D_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if is_enabled:
		if not is_dragging and event.is_action_pressed("ui_select"):
			print("Selected: ", actor_name)
			get_tree().set_input_as_handled()
			set_selected()

func move(new_location):
	print("Moved: ", actor_name)
	is_dragging = false
	is_selected = false
	position = new_location
	reset_line()
	reset_ghost()
	
func cancel_move():
	move(self.position)
#	is_selected = false
	
func potential_move(potential_location):
	update_ghost(potential_location)
	update_line(potential_location)

func update_look_direction(direction):
	$Pivot/Sprite.rotation = direction.angle()

func set_selected():
	emit_signal("game_piece_selected", self)
	$Highlight.visible = true
	is_selected = true
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
	

func _set_is_enabled(value: bool):
	""" This team's turn!"""
	print("is_enabled ", value, actor_name)
	is_enabled = value	
	
func _on_FlipButton_pressed() -> void:
	# Flip to new actor type
	if is_enabled:
		print("flipping!")
		emit_signal("game_piece_flip_pressed", self)
	

############## MOVEMENT ###################

func get_movement_array() -> Array:
	var width = 31
	var center = Vector2(15,15) 
	var move_array: Array = []
	match movement_type:
		MOVEMENT_TYPES.STATIONARY:
			pass
		MOVEMENT_TYPES.KING:
			move_array = [
				[1, 1, 1],
				[1, 0, 1],
				[1, 1, 1]
			]
		MOVEMENT_TYPES.KING_TWICE:
			move_array = [
				[1, 1, 1, 1, 1],
				[1, 1, 1, 1, 1],
				[1, 1, 0, 1, 1],
				[1, 1, 1, 1, 1],
				[1, 1, 1, 1, 1]
			]
		MOVEMENT_TYPES.QUEEN:
			for y in range(width):
				move_array.append([])
				for x in range(width):
					if Vector2(x, y) == center:
						move_array[y].append(0)
					elif x == center.x or y == center.y or abs(x - center.x) == abs(y - center.y):
						move_array[y].append(1)
					else:
						move_array[y].append(0)	
		MOVEMENT_TYPES.ROOK:
			# generate 31 x 31 array in a loop
			for y in range(width):
				move_array.append([])
				for x in range(width):
					if Vector2(x, y) == center:
						move_array[y].append(0)
					elif x == center.x or y == center.y:
						move_array[y].append(1)
					else:
						move_array[y].append(0)
	return move_array	
