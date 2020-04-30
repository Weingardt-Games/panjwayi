extends Label

func _ready() -> void:
	pass

func _on_PhaseController_phase_changed(phase) -> void:
	self.text = phase
