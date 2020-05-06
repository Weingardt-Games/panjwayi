extends Node2D

var valid_color = Color.greenyellow
var invalid_color = Color.red
var current_color
var can_place

# Placement Mode Variables
var placement_mode = false
var in_menu = false
var current_tile = Vector2()
var current_piece: Actor


onready var Grid = get_node("/root/Game/Grid")

signal actor_placed(current_actor)

func _ready() -> void:
	pass
	
func start_new_placement(actor: Actor):
	placement_mode = true
	current_piece = actor
	$TextureRect.texture = actor.get_node("Sprite").texture
	show()
	
func process_placement():
	if placement_mode:
		var mouse_pos = get_global_mouse_position()
		current_tile = Grid.world_to_map(mouse_pos)
		_update_placement_tool(Grid, current_piece, current_tile)
		if Input.is_action_just_pressed("ui_place"):
			_place_piece()
			
		if Input.is_action_just_pressed("ui_cancel"):
			_cancel_placement(true)
			
			
func _place_piece():
	if can_place and not in_menu:
		Grid.set_cellv(current_tile, Pawn.CELL_TYPES.ACTOR)
		current_piece.global_position = Grid.get_world_position(current_tile)
		emit_signal("actor_placed", current_piece)
		_cancel_placement()
		
func _cancel_placement(replace=false):
	placement_mode = false
	current_piece = null
	hide()

func _update_placement_tool(grid: PanjwayiTileMap, current_piece, current_tile):

#	print("CURRENT TILE: ", current_tile)
	position = grid.get_world_position(current_tile)
	
#	print(Grid.get_cellv(current_tile))
#	print(current_tile)
	
	var legal_placement_cell
	if current_piece.team == Actor.TEAM.GOA:
		legal_placement_cell = Pawn.CELL_TYPES.LEGAL_GOA_PLACEMENT
	else:
		legal_placement_cell = Pawn.CELL_TYPES.LEGAL_TALIBAN_PLACEMENT

	var current_cell_type = grid.get_cellv(current_tile)
	if current_cell_type == legal_placement_cell and current_color != valid_color:
		current_color = valid_color
		can_place = true
		$ColorRect.color = current_color

	if current_cell_type != legal_placement_cell and current_color != invalid_color:
		current_color = invalid_color
		can_place = false

		$ColorRect.color = current_color
		
