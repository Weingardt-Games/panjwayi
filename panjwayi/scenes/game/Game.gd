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


# GoA Piece Scenes
export(Array, PackedScene) var goa_pieces
export(Array, PackedScene) var taliban_pieces
var current_piece
var current_button


func _ready():
	generate_placement_buttons()


func _process(delta: float) -> void:
	_process_placement()


######### PLACEMENT / SETUP ####################

func _process_placement():
	if placement_mode:
		_update_placement_tool()
		if Input.is_action_just_pressed("ui_accept"):
			place_piece()
			
		if Input.is_action_just_pressed("ui_cancel"):
			cancel_placement(true)

func _update_placement_tool():
	var mouse_pos = get_global_mouse_position()
	current_tile = Grid.world_to_map(mouse_pos)
#	print("CURRENT TILE: ", current_tile)
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
		PlacementButtonContainer.remove_child(current_button)
		cancel_placement()
	
func cancel_placement(replace=false):
	placement_mode = false
	PlacementTool.hide()

func _on_Select_Piece_button_down(button: PlacementButton) -> void:
	placement_mode = true
	current_piece = goa_pieces[button.goa_piece_index]
	current_button = button
	$PlacementTool/TextureRect.texture = button.get_node("TextureRect").texture
	$PlacementTool.show()

func _on_Select_Piece_button_mouse_entered() -> void:
	in_menu = true
	
func _on_Select_Piece_button_mouse_exited() -> void:
	in_menu = false
	

################ SETUP ###################

onready var PlacementButtonContainer = $UI/PlacementUI/HBoxContainer
onready var PlacementButton = preload("res://scenes/game/hud/PlacementButton.tscn")

func generate_placement_buttons():
	for i in goa_pieces.size():
		var piece = goa_pieces[i]
		piece = piece.instance()
		print("generating placement buttons for: ", piece.actor_name)
		var button = PlacementButton.instance()
		button.get_node("TextureRect").texture = piece.sprite
		button.goa_piece_index = i
		PlacementButtonContainer.add_child(button)
		
		button.connect("selected", self, "_on_Select_Piece_button_down")
		button.connect("mouse_entered", self, "_on_Select_Piece_button_mouse_entered")
		button.connect("mouse_exited", self, "_on_Select_Piece_button_mouse_exited")
