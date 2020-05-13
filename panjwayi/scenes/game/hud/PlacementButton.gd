extends TextureButton
class_name PlacementButton

signal selected(actor)

# store the index of the goa piece when the button is created, so we can figure 
# out which piece this button should create
var actor_type: int # Actor.ACTOR_TYPES enum 
var team: int # Pawn.TEAM enum

func _ready() -> void:
	connect("button_down", self, "_on_Button_down")
	
func _on_Button_down():
	emit_signal("selected", self)
	$Sound.play()
