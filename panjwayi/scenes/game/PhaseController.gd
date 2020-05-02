extends Node
class_name PhaseController

const PHASES = {
	"GOA_SETUP": "GoA Setup",
	"TALIBAN_SETUP": "Taliban Setup",
	"TALIBAN_TURN": "Taliban Turn",
	"GOA_TURN": "GoA Turn"
}
var phase setget set_phase

signal phase_changed(phase)

func start() -> void:
	# call setter
	self.phase = PHASES.GOA_SETUP

func set_phase(new_phase):
	phase = new_phase
	print("New phase: ", phase)
	emit_signal("phase_changed", phase)

func next_phase():
	if phase == PHASES.GOA_SETUP:
		self.phase = PHASES.TALIBAN_SETUP
	elif phase == PHASES.TALIBAN_SETUP or phase == PHASES.GOA_TURN:
		self.phase = PHASES.TALIBAN_TURN
	elif phase == PHASES.TALIBAN_TURN:
		self.phase = PHASES.GOA_TURN
	else:
		print("Unrecognized PHASE")
			

func _on_PhaseCompleteButton_pressed() -> void:
	# Change phases
	next_phase()
	
	
