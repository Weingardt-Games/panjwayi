extends Node2D

onready var Grid = $Grid
onready var PlacementTool = $PlacementTool
onready var PlacementUI = find_node("PlacementUI")
onready var GoaGUI = find_node("GoaGUI")
onready var TalibanGUI = find_node("TalibanGUI")

var current_button


onready var TEAM_GUI_DICT = {
	Actor.TEAM.GOA:	GoaGUI,
	Actor.TEAM.TALIBAN: TalibanGUI
}

var current_phase = PhaseController.PHASES.GOA_SETUP

onready var PlacementButtonContainer = find_node("PlacementUI").find_node("Container")
onready var PlacementButton = preload("res://scenes/game/hud/PlacementButton.tscn")


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
#export(Array, PackedScene) var pieces

onready var pieces: Array = [
	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.AIR],
	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.LAV],
	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.LAV],
	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.ANA],
	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.ANA],
	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.ANP],
	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.ANP],
]
	

export(int, 1, 10) var number_of_taliban = 9
export(PackedScene) var taliban_piece

func _ready():
	# Wait till the game is ready or signals can fire before the game is ready for them!
	$PhaseController.start()
	GoaGUI.show()
	TalibanGUI.show()

func _process(delta: float) -> void:
	
	match current_phase:
		PhaseController.PHASES.GOA_SETUP:
			PlacementTool.process_placement()
			
		PhaseController.PHASES.TALIBAN_SETUP:
			PlacementTool.process_placement()
			
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
			_ready_placement()
			PlacementUI.set_color(GoaGUI.team_color)
			PlacementUI.visible = true
			PlacementUI.rect_position = $PositionMarkers/PlacementUIGoA.rect_position
		
		PhaseController.PHASES.TALIBAN_SETUP:
			# fill out the taliban pieces:
			pieces = []
			for i in number_of_taliban:
				pieces.append(taliban_piece)
	
			_ready_placement()
			PlacementUI.set_color(TalibanGUI.team_color)
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

		
func is_all_pieces_placed():
	return PlacementButtonContainer.get_child_count() == 0
	

func _on_PlacementTool_actor_placed(current_actor) -> void:
	insert_actor(current_actor)
	PlacementButtonContainer.remove_child(current_button)
	
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
	
func insert_actor(actor: Actor):
	# connect to the flip signal if needed
	actor.connect("game_piece_flip_pressed", self, "_on_GamePiece_flip_pressed")
	actor.connect("game_piece_dragged", self, "_on_GamePiece_dragged")
	actor.connect("game_piece_dropped", self, "_on_GamePiece_dropped")
	actor.connect("game_piece_selected", self, "_on_GamePiece_selected")
	actor.connect("game_piece_movement_cancelled", self, "_on_GamePiece_movement_cancelled")
	
	Grid.add_child(actor)
	

func _on_GamePiece_flip_pressed(actor: Actor):
	var flip_scene = ACTOR_SCENES_DICT.get(actor.flip_side)
	var flip_piece = flip_scene.instance()
	flip_piece.global_position = actor.global_position
	insert_actor(flip_piece)
	actor.queue_free()

func _on_Select_Piece_button_down(button: PlacementButton) -> void:
	current_button = button
	# TEMPRARY DISABLE TILL GET REINFORCEMENTS WORKING
	if current_phase == PhaseController.PHASES.GOA_SETUP or current_phase == PhaseController.PHASES.TALIBAN_SETUP:
		PlacementTool.start_new_placement(
			pieces[button.goa_piece_index].instance(),
			button.get_node("TextureRect").texture
		)

func _on_Select_Piece_button_mouse_entered() -> void:
	PlacementTool.in_menu = true
	
func _on_Select_Piece_button_mouse_exited() -> void:
	PlacementTool.in_menu = false


################ SETUP ###################

func _ready_placement():

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
		

###############  TURN ######################
func _ready_game_for_turns():
	# reset the Grid for movement:
	Grid.prepare_board_for_game_start()

func _on_GamePiece_movement_cancelled():
	Grid.clear_movement()
	
func _on_GamePiece_selected(actor: Actor):
	Grid.prep_movement(actor)

func _on_GamePiece_dropped(actor: Actor, new_location: Vector2) -> void:
	var potential_location = Grid.request_move(actor, new_location, true)
	Grid.clear_movement()
	if potential_location:
		actor.move(potential_location)
	else:
		actor.cancel_move()
		print("Can't go there!")

func _on_GamePiece_dragged(actor: Actor, new_location: Vector2) -> void:
	var potential_location = Grid.request_move(actor, new_location)
	if potential_location:
		actor.potential_move(potential_location)
	else:
		actor.potential_move(actor.position)
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
	
### ATTACKS #################
func _on_Grid_piece_destroyed(actor: Actor) -> void:
	""" Occurs when an actor has been destroyed and removed from the Grid
	Put the Actor in it's team's Destroyed box.
	"""
	print("generating placement buttons for: ", actor.actor_name)
	var button = PlacementButton.instance()
	button.get_node("TextureRect").texture = actor.sprite
#	button.goa_piece_index = i
	(TEAM_GUI_DICT[actor.team] as TeamGUI).add_actor_to_destroyed(button)
#	PlacementButtonContainer.add_child(button)
	button.connect("selected", self, "_on_Select_Piece_button_down")
	button.connect("mouse_entered", self, "_on_Select_Piece_button_mouse_entered")
	button.connect("mouse_exited", self, "_on_Select_Piece_button_mouse_exited")	
	
