extends Node2D

onready var Grid = $Grid
onready var PlacementTool = $PlacementTool
onready var PlacementUI = find_node("PlacementUI")
onready var GoaGUI = find_node("GoaGUI")
onready var TalibanGUI = find_node("TalibanGUI")
onready var clickSound = $ClickSound
onready var deathSound = $DeathSound
onready var phase_controller = $PhaseController
onready var info_panel = $UI/InfoPanel

enum ACTIONS {
	PLACE_IED,
	REMOVE_IED,
	REPLACE_IED,
	FLIP,
	MOVE,
	ATTACK,
	REINFORCEMENT		
}
var last_action
var current_action
var current_button
var current_actor: Actor

onready var TEAM_GUI_DICT = {
	Actor.TEAM.GOA:	GoaGUI,
	Actor.TEAM.TALIBAN: TalibanGUI
}

onready var confimationDialog = $UI/ConfirmationDialog
onready var placementButtonContainer = find_node("PlacementUI").find_node("Container")
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

onready var starting_actors: Array = [
	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.AIR],
	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.LAV],
#	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.LAV],
#	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.ANA],
#	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.ANA],
#	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.ANP],
#	ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.ANP],
]

export(int, 1, 10) var number_of_taliban = 1


func _ready():
	# Wait till the game is ready or signals can fire before the game is ready for them!
	$PhaseController.start()
	GoaGUI.show()
	TalibanGUI.show()
	
	confimationDialog.get_cancel().connect("pressed", self, "_on_ConfirmationDialog_cancelled")

func _process(delta: float) -> void:
	
	match phase_controller.phase:
		PhaseController.PHASES.GOA_SETUP:
			PlacementTool.process_placement()
			
		PhaseController.PHASES.TALIBAN_SETUP:
			PlacementTool.process_placement()
			
		PhaseController.PHASES.GOA_TURN:
			PlacementTool.process_placement()
			TalibanGUI.set_disabled(true)
			GoaGUI.set_disabled(false)
			
		PhaseController.PHASES.TALIBAN_TURN:
			PlacementTool.process_placement()
			TalibanGUI.set_disabled(false)
			GoaGUI.set_disabled(true)
			
		_:
			pass
	update_info_panel()
	
	
func update_info_panel():
	var mouse_pos = get_global_mouse_position()
	var cell = Grid.world_to_map(mouse_pos)
	info_panel.set_cell(cell)
	info_panel.set_type(Grid.get_cellv(cell))
	
	info_panel.set_actor(Grid.get_actor(cell))
	info_panel.set_village(Grid.get_village(cell))
		

func _on_PhaseController_phase_changed(phase) -> void:
	print("Game current phase:", phase)
	GoaGUI.set_phase(phase_controller.get_phase_string())
	TalibanGUI.set_phase(phase_controller.get_phase_string())
	
	match phase:
		PhaseController.PHASES.GOA_SETUP:
			_ready_placement()
			PlacementUI.set_color(GoaGUI.team_color)
			PlacementUI.visible = true
			PlacementUI.rect_position = $PositionMarkers/PlacementUIGoA.rect_position
		
		PhaseController.PHASES.TALIBAN_SETUP:
			# fill out the taliban actors:
			starting_actors = []  # should already be empty
			for i in number_of_taliban:
				var taliban_actor = ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.INS]
				starting_actors.append(taliban_actor)
	
			_ready_placement()
			_ready_reinforcements()
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

		
func is_all_starting_actors_placed():
	return placementButtonContainer.get_child_count() == 0
	
	
func _on_PlacementTool_placement_cancelled(new_current_actor) -> void:
	Grid.clear_placement()


func _on_PlacementTool_actor_placed(new_current_actor) -> void:
	current_actor = new_current_actor
	insert_actor(current_actor)
	# get parent because could be any one of three panels (setup, reinforcements, destroyed)
	current_button.get_parent().remove_child(current_button)
	clickSound.play()
	Grid.clear_placement()

	if phase_controller.is_setup():
		# when all the starting_actors are placed, activate button to finish setup phase
		if is_all_starting_actors_placed():
			if phase_controller.is_taliban_setup():
				TalibanGUI.button_is_active = true
			elif phase_controller.is_goa_setup():
				GoaGUI.button_is_active = true
	else:
		current_action = ACTIONS.REINFORCEMENT
		confimationDialog.popup_centered()
	
func placement_complete():
	PlacementUI.visible = false
	
func insert_actor(actor: Actor):
	# connect to the flip signal if needed
	actor.connect("flip_pressed", self, "_on_Actor_flip_pressed")
	actor.connect("dragged", self, "_on_Actor_dragged")
	actor.connect("dropped", self, "_on_Actor_dropped")
	actor.connect("selected", self, "_on_Actor_selected")
	actor.connect("movement_cancelled", self, "_on_Actor_movement_cancelled")
	
	Grid.add_child(actor)
	

func _on_Actor_flip_pressed(actor: Actor):
	var flip_scene = ACTOR_SCENES_DICT.get(actor.flip_side)
	var flip_actor = flip_scene.instance()
	flip_actor.global_position = actor.global_position
	insert_actor(flip_actor)
	actor.queue_free()
	clickSound.play()
	current_actor = flip_actor
	current_action = ACTIONS.FLIP
	if not phase_controller.is_setup():
		confimationDialog.popup_centered()
	

func _on_Select_Piece_button_down(button: PlacementButton) -> void:
	current_button = button
	# TEMPRARY DISABLE TILL GET REINFORCEMENTS WORKING
#	if phase_controller.is_setup():
	PlacementTool.start_new_placement(
		# should generate the piece from the dict, not here.
		ACTOR_SCENES_DICT[button.actor_type].instance(),
		button.get_node("TextureRect").texture
	)
	
	if phase_controller.is_setup():
		Grid.prep_setup_placement(button.team)
	else:
		Grid.prep_placement(button.actor_type, button.team)
	clickSound.play()

func _on_Select_Piece_button_mouse_entered() -> void:
	PlacementTool.in_menu = true
	
func _on_Select_Piece_button_mouse_exited() -> void:
	PlacementTool.in_menu = false


################ SETUP ###################

func _ready_placement():
	for i in starting_actors.size():
		var actor = starting_actors[i].instance()
		var button = create_button(actor)
		placementButtonContainer.add_child(button)
		
func _ready_reinforcements():
	""" Taliban start with two IED units in the reinforcements box """
	var num_ieds = 2

	for i in num_ieds:
		var ied = ACTOR_SCENES_DICT[Actor.ACTOR_TYPES.IED].instance()
		var button = create_button(ied)
		TalibanGUI.add_actor_to_reinforcements(button)
		
func create_button(actor):
	print("generating placement buttons for: ", actor.actor_name)
	var button = PlacementButton.instance()
	button.get_node("TextureRect").texture = actor.sprite
	button.actor_type = actor.actor_type
	button.team = actor.team
	button.connect("selected", self, "_on_Select_Piece_button_down")
	button.connect("mouse_entered", self, "_on_Select_Piece_button_mouse_entered")
	button.connect("mouse_exited", self, "_on_Select_Piece_button_mouse_exited")
	return button

###############  TURN / MOVEMENT ######################
func _ready_game_for_turns():
	# reset the Grid for movement:
	Grid.prepare_board_for_game_start()

func _on_Actor_movement_cancelled():
	Grid.clear_movement()
	
func _on_Actor_selected(actor: Actor):
	current_actor = actor
	Grid.prep_movement(actor)
	clickSound.play()

func _on_Actor_dropped(actor: Actor, new_location: Vector2) -> void:
	var potential_location = Grid.request_move(actor, new_location, true)
	Grid.clear_movement()
	if potential_location:
		actor.move(potential_location)
		clickSound.play()
		current_action = ACTIONS.MOVE
		confimationDialog.popup_centered()
	else:
		actor.cancel_move()
		print("Can't go there!")

func _on_Actor_dragged(actor: Actor, new_location: Vector2) -> void:
	var potential_location = Grid.request_move(actor, new_location)
#	print(potential_location)
	if potential_location:
		actor.potential_move(potential_location)
	else:
		actor.potential_move(actor.position)
		

func _on_ConfirmationDialog_cancelled() -> void:
	print("Cancelling")
	# move the piece back to its previous position.  Must be open so no need to check
	match current_action:
		ACTIONS.MOVE:
			current_actor.move(
				Grid.request_move(current_actor, current_actor.previous_position, false, true)
			)
		ACTIONS.FLIP:
			_on_Actor_flip_pressed(current_actor)
		ACTIONS.PLACE_IED:
			pass
		ACTIONS.REINFORCEMENT:
			pass
		ACTIONS.REMOVE_IED:
			pass
		ACTIONS.REPLACE_IED:
			pass

func _on_ConfirmationDialog_confirmed() -> void:
	last_action = current_action
	$PhaseController.next_phase()
	
func get_current_actors_on_board() -> Array:
	var actors = []
	for child in Grid.get_children():
		if child is Actor:
			actors.append(child)
	return actors

func _ready_turn(team_turn):
	for a in get_current_actors_on_board():
		var actor = a as Actor
		if actor.team == team_turn:
			actor.is_enabled = true
			actor.set_selectable()
		else:
			actor.is_enabled = false
	pass
	
### ATTACKS #################
func _on_Grid_actor_destroyed(actor: Actor) -> void:
	""" Occurs when an actor has been destroyed and removed from the Grid
	Put the Actor in it's team's Destroyed box.
	"""
	print("generating placement buttons for: ", actor.actor_name)
	var button = create_button(actor)
	(TEAM_GUI_DICT[actor.team] as TeamGUI).add_actor_to_destroyed(button)
	deathSound.play()


func _on_GoaGUI_done_button_clicked() -> void:
	$PhaseController.next_phase()
	clickSound.play()


func _on_TalibanGUI_done_button_clicked() -> void:
	$PhaseController.next_phase()
	placement_complete()
	_ready_game_for_turns()
	clickSound.play()


func _on_Grid_village_captured(village: Village) -> void:
	print(village.village_name, " Captured!")
	deathSound.play()
	village.toggle_team()
