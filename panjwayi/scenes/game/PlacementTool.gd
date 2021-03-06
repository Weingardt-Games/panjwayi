extends Node2D

var valid_color = Color.transparent
var invalid_color = Color.red
var current_color
var can_place

# Placement Mode Variables
var placement_mode = false
var in_menu = false
var current_tile = Vector2()
var current_actor: Actor


onready var Grid: TileMap = get_node("/root/Game/Grid")

signal actor_placed(current_actor)
signal placement_cancelled(current_actor)

func _ready() -> void:
	pass
	
func start_new_placement(actor: Actor, texture: Texture):
	placement_mode = true
	current_actor = actor
	$TextureRect.texture = texture
	show()
	
func process_placement():
	if placement_mode:
		var mouse_pos = get_global_mouse_position()
		current_tile = Grid.world_to_map(mouse_pos)
		_update_placement_tool(Grid)
		if Input.is_action_just_pressed("ui_place") or Input.is_action_just_released("ui_place"):
			_place_actor()
			print("placing!")
		if Input.is_action_just_pressed("ui_cancel"):
			emit_signal("placement_cancelled", current_actor)
			_cancel_placement(true)
			
			
func _place_actor():
#	print("in_menu", in_menu)
#	print("can_place", can_place)
	if can_place: # current cell is a valid placement cell
		Grid.set_cellv(current_tile, Pawn.CELL_TYPES.ACTOR)
		current_actor.global_position = Grid.get_world_position(current_tile)
		emit_signal("actor_placed", current_actor)
		_cancel_placement()
#		print("Actor placed: ", current_actor)
		
func _cancel_placement(replace=false):
	placement_mode = false
	current_actor = null
	hide()

func _update_placement_tool(grid: PanjwayiTileMap):

	position = grid.get_world_position(current_tile)

	var current_cell_type = grid.get_cellv(current_tile)
	if current_cell_type == Pawn.CELL_TYPES.LEGAL_PLACEMENT and current_color != valid_color:
		current_color = valid_color
		can_place = true
		$ColorRect.color = current_color

	if current_cell_type != Pawn.CELL_TYPES.LEGAL_PLACEMENT and current_color != invalid_color:
		current_color = invalid_color
		can_place = false

		$ColorRect.color = current_color

func place_randomly(actor: Actor):
	current_actor = actor
	can_place = true
	# pick a random cell/tile
	Grid.prep_setup_placement(actor.team)
	var placeable_cells = Grid.get_used_cells_by_id(Pawn.CELL_TYPES.LEGAL_PLACEMENT)
	var i = randi() % len(placeable_cells)
	current_tile = placeable_cells[i]
	_place_actor()
	print("Placing actor randomly in cell", current_tile)
#	# Wait 5 seconds, then resume execution.
#	yield(get_tree().create_timer(1.5), "timeout")
#	can_place=false
#
