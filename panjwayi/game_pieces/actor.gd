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
	ROOK,
	IED
}

enum STATUSES {
	ACTIVE,
	DESTROYED,
	REINFORCEMENT,
	PERMANENTLY_DESTROYED	
}

export(String) var actor_name
export(ACTOR_TYPES) var actor_type = ACTOR_TYPES.NONE

export(MOVEMENT_TYPES) var movement_type = MOVEMENT_TYPES.KING
export(Array, ACTOR_TYPES) var pass_overable_units = [ACTOR_TYPES.NONE]
export(String) var movement_description

export(Array, ACTOR_TYPES) var attackable_units = [ACTOR_TYPES.NONE]
export(String) var attack_description
export(bool) var captures_villages

export(String) var Special

export(ACTOR_TYPES) var flip_side = ACTOR_TYPES.NONE

export(STATUSES) var status

var is_mouse_still_inside = true  # tracks whether the mouse has left the actor or not
var is_dragging = false
var is_enabled = false setget _set_is_enabled
var is_selected = false

var previous_position: Vector2

signal dropped(actor, new_location)
signal dragged(actor, new_location)
signal selected(actor)
signal flip_pressed(actor)
signal movement_cancelled()

func _ready() -> void:
	$Sprite.texture = sprite
	$Ghost.texture = sprite
	
	if flip_side != ACTOR_TYPES.NONE:
		$FlipButton.visible = true
	else:
		$FlipButton.visible = false
		
	
func _unhandled_input(event: InputEvent) -> void:
	# ALL input events
	
	# There is no _is_action_just_pressed here because of the echo thing...
	#https://godotengine.org/qa/45910/how-to-get-key_a-or-any-other-key-just-pressed
#	var just_pressed = event.is_pressed() and not event.is_echo()
	
	if is_selected:
		if event.is_action_released("ui_select") or event.is_action_pressed("ui_select"): 
			# if the mouse is still over the actor, leave it selected
			if not is_mouse_still_inside:	
				print("Released: ", actor_name)
				emit_signal("dropped", self, get_global_mouse_position())
				# so it doesn't immediately reselect the actor if it was placed with a click (instead of release)
				get_tree().set_input_as_handled()
			
		if event is InputEventMouseMotion:
#			print("Dragged: ", actor_name)
			emit_signal("dragged", self, get_global_mouse_position())
			
		if event.is_action_pressed("ui_cancel"):
			cancel_move()
			print("Cancelled: ", actor_name)
			emit_signal("movement_cancelled")

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
	previous_position = position
	is_dragging = false
	is_selected = false
	position = new_location
	reset_line()
	reset_ghost()
	z_index = 0
	
func cancel_move():
	move(self.position)
	set_selectable()
#	is_selected = false
	
func potential_move(potential_location):
	update_ghost(potential_location)
	update_line(potential_location)

func update_look_direction(direction):
	$Pivot/Sprite.rotation = direction.angle()

func set_selected():
	emit_signal("selected", self)
	$SelectedHighlight.visible = true
	$SelectableHighlight.visible = false
	is_selected = true
	is_dragging = true
	is_mouse_still_inside = true
	z_index = 100
	
func set_selectable():
	if not is_selected and is_enabled:
		$SelectableHighlight.visible = true
		
func reset_selectable():
	$SelectableHighlight.visible = false
	
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
	$SelectedHighlight.visible = false
	reset_selectable()
	$Ghost.visible = false
	$Ghost.position = Vector2.ZERO
	

func _set_is_enabled(value: bool):
	""" This team's turn!"""
#	print("is_enabled ", value, actor_name)
	is_enabled = value
	$FlipButton.disabled = !value
	
	if not is_enabled:
		reset_selectable()
	
	
func _on_FlipButton_pressed() -> void:
	# Flip to new actor type
	if is_enabled:
		print("flipping!")
		emit_signal("flip_pressed", self)
	

############## MOVEMENT ###################

func get_movement_array() -> Array:
	var width = 31
	var center = Vector2(15,15) 
	var move_array: Array = []
	match movement_type:
		# but not around self...
		MOVEMENT_TYPES.IED:
			move_array = [
				[1, 1, 1],
				[1, 0, 1],
				[1, 1, 1]
			]
		MOVEMENT_TYPES.STATIONARY:
			move_array = []
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


func _on_Area2D_mouse_exited() -> void:
	is_mouse_still_inside = false	
