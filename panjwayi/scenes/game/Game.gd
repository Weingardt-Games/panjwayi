extends Node2D

var placement_mode = false

onready var Grid = $Grid
onready var PlacementTool = $PlacementTool

# Placement Mode Variables
var valid_color = Color.greenyellow
var invalid_color = Color.red
var current_color
var can_place = false
var in_menu = false
var current_tile = Vector2()

#Placement Mode Textures
export(Array, Texture) var goa_textures
export(Array, Texture) var taliban_textures

# GoA Piece Scenes
export(Array, PackedScene) var goa_pieces
export(Array, PackedScene) var taliban_pieces
var current_piece


func _process(delta: float) -> void:
	if placement_mode:
		_update_placement_tool()
		if Input.is_action_just_pressed("ui_accept"):
			place_piece()
			pass
			
		if Input.is_action_just_pressed("ui_cancel"):
			placement_mode = false
			PlacementTool.hide()

func _update_placement_tool():
	var mouse_pos = get_global_mouse_position()
	current_tile = Grid.world_to_map(mouse_pos)
	print("CURRENT TILE: ", current_tile)
	PlacementTool.position = Grid.get_world_position(current_tile)
	
	if Grid.get_cellv(current_tile) != Pawn.CELL_TYPES.ACTOR and current_color != valid_color:
		current_color = valid_color
		can_place = true
		$PlacementTool/ColorRect.color = current_color

	if Grid.get_cellv(current_tile) == Pawn.CELL_TYPES.ACTOR and current_color != invalid_color:
		current_color = invalid_color
		can_place = false
		$PlacementTool/ColorRect.color = current_color
	
func place_piece():
	if can_place and not in_menu:
		Grid.set_cellv(current_tile, Pawn.CELL_TYPES.ACTOR)
		var new_piece = current_piece.instance()
		new_piece.global_position = Grid.get_world_position(current_tile)
		$GoAPieceContainer.add_child(new_piece)
		
	


func _on_Select_Piece_button_down(piece: String) -> void:
	print(piece) 
	placement_mode = true
	$PlacementTool.show()


func _on_Select_Piece_button_mouse_entered() -> void:
	in_menu = true
	
func _on_Select_Piece_button_mouse_exited() -> void:
	in_menu = false

