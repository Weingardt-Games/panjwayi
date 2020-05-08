extends Node
class_name PhaseController

enum PHASES {
	GOA_SETUP,
	TALIBAN_SETUP,
	TALIBAN_TURN,
	GOA_TURN
}	

var PHASE_STRINGS = {
	PHASES.GOA_SETUP: "GoA Setup",
	PHASES.TALIBAN_SETUP: "Taliban Setup",
	PHASES.TALIBAN_TURN: "Taliban Turn",
	PHASES.GOA_TURN: "GoA Turn"
}
var phase:int setget set_phase

signal phase_changed(phase)

func start() -> void:
	# call setter
	self.phase = PHASES.GOA_SETUP

func set_phase(new_phase):
	phase = new_phase
	print("New phase: ", phase)
	emit_signal("phase_changed", phase)

func next_phase() -> int:
	if phase == PHASES.GOA_SETUP:
		self.phase = PHASES.TALIBAN_SETUP
	elif phase == PHASES.TALIBAN_SETUP or phase == PHASES.GOA_TURN:
		self.phase = PHASES.TALIBAN_TURN
	elif phase == PHASES.TALIBAN_TURN:
		self.phase = PHASES.GOA_TURN

	return -1
			
func get_phase_string() -> String:
	return 	PHASE_STRINGS[phase]
	
func is_taliban_setup() -> bool:
	return phase == PHASES.TALIBAN_SETUP
	
func is_goa_setup() -> bool:
	return phase == PHASES.GOA_SETUP
	
func is_setup() -> bool:
	return is_taliban_setup() or is_goa_setup()

############### SIGNALS #################
func _on_PhaseCompleteButton_pressed() -> void:
	# Change phases
	next_phase()
	
	
