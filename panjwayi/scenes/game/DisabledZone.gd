extends ColorRect

func _ready() -> void:
	pass


func _on_PhaseController_phase_changed(phase) -> void:
	match phase:
		PhaseController.PHASES.GOA_SETUP:
			visible = true
			rect_position = Vector2(0, 64*4)

		PhaseController.PHASES.TALIBAN_SETUP:
			visible = true
			rect_position = Vector2(0, 0)
		_:
			visible = false
