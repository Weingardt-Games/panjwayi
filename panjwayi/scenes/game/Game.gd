extends Node2D

var placement_mode = false

onready var Grid = $Grid
onready var PlacementTool = $PlacementTool
onready var PlacementUI = find_node("PlacementUI")

# Placement Mode Variables
var valid_color = Color.greenyellow
var invalid_color = Color.red
var current_color
var can_place = false
var in_menu = false
var current_tile = Vector2()
var current_phase = PhaseController.PHASES.GOA_SETUP

var ACTOR_SCENES_DICT = {
	Actor.ACTOR_TYPES.AIR: load("res://game_pieces/goa_pieces/AIR.tscn"),
	Actor.ACTOR_TYPES.LAV: load("res://game_pieces/goa_pieces/LAV.tscn"),
	Actor.ACTOR_TYPES.INY: load("res://game_pieces/goa_pieces/INF.tscn"),
	Actor.ACTOR_TYPES.ANA: load("res://game_pieces/goa_pieces/ANA.tscn"),
	Actor.ACTOR_TYPES.ANP: load("res://game_pieces/goa_pieces/ANP.tscn"),
	Actor.ACTOR_TYPES.INS: load("res://game_pieces/taliban_pieces/INS.tscn"),
	Actor.ACTOR_TYPES.POP: load("res://game_pieces/taliban_pieces/POP.tscn"),
	Actor.ACTOR_TYPES.IED: load("res://game_pieces/taliban_pieces/IED.tscn"),
}

# Piece Scenes
export(Array, PackedScene) var pieces

export(int, 1, 10) var number_of_taliban = 9
export(PackedScene) var taliban_piece

var current_piece: Actor
var current_button

func _ready():
	# Wait till the game is ready or signals can fire before the game is ready for them!
	$PhaseController.start()

func _process(delta: float) -> void:
	
	match current_phase:
		PhaseController.PHASES.GOA_SETUP:
			_process_placement()
			
		PhaseController.PHASES.TALIBAN_SETUP:
			_process_placement()
			
		PhaseController.PHASES.GOA_TURN:
			pass
			
		PhaseController.PHASES.TALIBAN_TURN:
			pass
			
		_:
			pass

func _on_PhaseController_phase_changed(phase) -> void:
	current_phase = phase
	print("Game current pahse:", current_phase)
	match current_phase:
		PhaseController.PHASES.GOA_SETUP:
			#pieces start with all the GoA scenes as an export	
			_ready_placement(pieces)
			PlacementUI.visible = true
			PlacementUI.rect_position = $PositionMarkers/PlacementUIGoA.rect_position
		
		PhaseController.PHASES.TALIBAN_SETUP:
			# fill out the taliban pieces:
			pieces = []
			for i in number_of_taliban:
				pieces.append(taliban_piece)
	
			_ready_placement(pieces)
			PlacementUI.visible = true
			PlacementUI.rect_position = $PositionMarkers/PlacementUITaliban.rect_position
		
					
		PhaseController.PHASES.TALIBAN_TURN:
			print("ready turn taliban")
			_ready_turn(Actor.TEAM.TALIBAN)
			
		PhaseController.PHASES.GOA_TURN:
			_ready_turn(Actor.TEAM.GOA)

		_:
			pass

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
	
#	print(Grid.get_cellv(current_tile))
#	print(current_tile)
	
	var legal_placement_cell
	if current_piece.team == Actor.TEAM.GOA:
		legal_placement_cell = Pawn.CELL_TYPES.LEGAL_GOA_PLACEMENT
	else:
		legal_placement_cell = Pawn.CELL_TYPES.LEGAL_TALIBAN_PLACEMENT

	var current_cell_type = Grid.get_cellv(current_tile)
	if current_cell_type == legal_placement_cell and current_color != valid_color:
		current_color = valid_color
		can_place = true
		$PlacementTool/ColorRect.color = current_color

	if current_cell_type != legal_placement_cell and current_color != invalid_color:
		current_color = invalid_color
		can_place = false

		$PlacementTool/ColorRect.color = current_color
		
func is_all_pieces_placed():
	return PlacementButtonContainer.get_child_count() == 0
	
func place_piece():
	if can_place and not in_menu:
		Grid.set_cellv(current_tile, Pawn.CELL_TYPES.ACTOR)
		current_piece.global_position = Grid.get_world_position(current_tile)
		
		insert_actor(current_piece)
		
		PlacementButtonContainer.remove_child(current_button)
		cancel_placement()
		
		if is_all_pieces_placed():
			if current_phase == PhaseController.PHASES.TALIBAN_SETUP:
				placement_complete()
				_ready_game_for_turns()
			$PhaseController.next_phase()
	
func placement_complete():
	# remove placement container?  or reuse for Reinforcemnts box?
	$DisabledZone.visible = false
	PlacementUI.visible = false
	pass
	
func cancel_placement(replace=false):
	placement_mode = false
	current_piece = null
	PlacementTool.hide()
	
func insert_actor(actor: Actor):
	# connect to the flip signal if needed
	actor.connect("game_piece_flip_pressed", self, "_on_GamePiece_flip_pressed")
	actor.connect("game_piece_dragged", self, "_on_GamePiece_dragged")
	actor.connect("game_piece_dropped", self, "_on_GamePiece_dropped")
	
	Grid.add_child(actor)
	
	
func _on_GamePiece_flip_pressed(actor: Actor):
	var flip_scene = ACTOR_SCENES_DICT.get(actor.flip_side)
	var flip_piece = flip_scene.instance()
	flip_piece.global_position = actor.global_position
	insert_actor(flip_piece)
	actor.queue_free()

func _on_Select_Piece_button_down(button: PlacementButton) -> void:
	placement_mode = true
	current_piece = pieces[button.goa_piece_index].instance()
	current_button = button
	$PlacementTool/TextureRect.texture = button.get_node("TextureRect").texture
	$PlacementTool.show()

func _on_Select_Piece_button_mouse_entered() -> void:
	in_menu = true
	
func _on_Select_Piece_button_mouse_exited() -> void:
	in_menu = false
	

################ SETUP ###################

onready var PlacementButtonContainer = find_node("PlacementUI").find_node("Container")
onready var PlacementButton = preload("res://scenes/game/hud/PlacementButton.tscn")

func _ready_placement(pieces):

	for i in pieces.size():
		var piece = pieces[i]
		piece = piece.instance()
		print("generating placement buttons for: ", piece.actor_name)
		var button = PlacementButton.instance()
		button.get_node("TextureRect").texture = piece.sprite
		button.goa_piece_index = i
		PlacementButtonContainer.add_child(button)
		
		button.connect("selected", self, "_on_Select_Piece_button_down")
		button.connect("mouse_entered", self, "_on_Select_Piece_button_mouse_entered")
		button.connect("mouse_exited", self, "_on_Select_Piece_button_mouse_exited")
		

############### GOA TURN ######################
func _ready_game_for_turns():
	# connect_movement signals to all the actors
	var actors = get_current_actors_on_board()
		
	# reset the Grid for movement:
	Grid.prepare_board_for_game_start()


func _on_GamePiece_dropped(actor, new_location) -> void:
	var potential_location = Grid.request_move(actor, new_location, true)
	Grid.clear_highlights()
	if potential_location:
		actor.move(potential_location)
	else:
		print("Can't go there!")

func _on_GamePiece_dragged(actor, new_location) -> void:
	Grid.highlight_movements(actor)
	var potential_location = Grid.request_move(actor, new_location)
	if potential_location:
		actor.potential_move(potential_location)
	else:
		print("Can't go there!")
	
func get_current_actors_on_board() -> Array:
	var actors: Array
	for child in Grid.get_children():
		if child is Actor:
			actors.append(child)
	return actors

func _ready_turn(team_turn):
	for a in get_current_actors_on_board():
		print(a.actor_name, a.name)
		var actor = a as Actor
		if actor.team == team_turn:
			actor.is_enabled = true
		else:
			actor.is_enabled = false
	pass
	
	
