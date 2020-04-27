extends "pawn.gd"
class_name GamePiece

onready var Grid = get_parent()

var is_dragging = false

func _ready() -> void:
	pass
	
func _input(event):
	if not is_dragging:
		return
		
	if event.is_action_released("ui_select_piece"):
		is_dragging = false
		reset_line()
		reset_ghost()
		var target_position = Grid.request_move(self, get_global_mouse_position(), true)
		if target_position:
			position = target_position
		
	if is_dragging and event is InputEventMouseMotion:
		var want_to_go_to = get_global_mouse_position()
		var target_position = Grid.request_move(self, want_to_go_to)
		if target_position and target_position != position:
			update_ghost(target_position)
			update_line(target_position)
		else:
			# Indicate illegal move
			pass
			
	
############ SIGNALS ######################

func _on_Area2D_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("ui_select_piece"):
		get_tree().set_input_as_handled()
		is_dragging = true

########### CUSTOM METHODS ##############

func get_input_direction():
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

func update_look_direction(direction):
	$Pivot/Sprite.rotation = direction.angle()

func move_to(target_position):
	position = target_position
	
func update_line(target_position):
	$Line2D.visible = true
	$Line2D.set_point_position(1, target_position - position)
	
func reset_line():
	$Line2D.visible = false
	$Line2D.set_point_position(1, Vector2.ZERO)
	
func update_ghost(target_position):
	$Highlight.visible = true
	$Ghost.visible = true
	$Ghost.position = target_position - position
	
func reset_ghost():
	$Highlight.visible = false
	$Ghost.visible = false
	$Ghost.position = Vector2.ZERO
