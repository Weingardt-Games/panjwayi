extends Control

onready var cellLabel = $VBoxContainer/Cell
onready var typeLabel = $VBoxContainer/Type
onready var villageLabel = $VBoxContainer/Village
onready var actorLabel = $VBoxContainer/Actor

func _ready() -> void:
	pass

func set_cell(cell: Vector2):
	cellLabel.text = "Cell: " + str(cell)
	
func set_type(type: int):
	typeLabel.text = "Cell Type: " + str(type) + " (" + Pawn.CELL_TYPES.keys()[type] + ")"

func set_village(village: Village):
	if village == null:
		villageLabel.text = "Village: None"
	else:
		villageLabel.text = "Village: " + village.village_name + " (" + Pawn.TEAM.keys()[village.team] + ")"
	
func set_actor(actor: Actor):
	if actor == null:
		actorLabel.text = "Actor: None"
	else:
		actorLabel.text = "Actor: " + actor.actor_name + " (" + Pawn.TEAM.keys()[actor.team] + ")"
