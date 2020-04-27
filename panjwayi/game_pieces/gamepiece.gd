extends "pawn.gd"
class_name GamePiece

onready var Grid = get_parent()

var start_position = Vector2()
var previous_mouse_position = Vector2()
var is_dragging = false

func _ready() -> void:
	pass
	
func _process(delta):
	update()
	
func _input(event):
	if not is_dragging:
		return
		
	if event.is_action_released("ui_select_piece"):
		start_position = position
		previous_mouse_position = Vector2()
		is_dragging = false
		$Highlight.visible = false
		
	if is_dragging and event is InputEventMouseMotion:
#		var want_to_go_to = position + event.position # - previous_mouse_position
		var want_to_go_to = get_global_mouse_position()
		var target_position = Grid.request_move(self, want_to_go_to)
		print("Position", position)
		print("Target:", target_position)
		print("Global mouse:", want_to_go_to)
		if target_position and target_position != position:
			print("moving!")
#			previous_mouse_position = event.position
			move_to(target_position)
		else:
			# Indicate illegal move
			pass
		previous_mouse_position = event.position

	
############ SIGNALS ######################

func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("ui_select_piece"):
		print(event)
		get_tree().set_input_as_handled()
		start_position = position
		previous_mouse_position = event.position
		is_dragging = true
		$Highlight.visible = true
		

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
