extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT}

const BOARD_SIZE = Vector2(16, 16)

func _ready():
	# Fill the TileMap Grid with PLACEMENT_CELL_TYPES
	for x in BOARD_SIZE.x:
		for y in BOARD_SIZE.y:
			if x < 4:
				set_cellv(Vector2(x, y), Pawn.CELL_TYPES.LEGAL_GOA_PLACEMENT)
			elif x >= 12:
				set_cellv(Vector2(x, y), Pawn.CELL_TYPES.LEGAL_TALIBAN_PLACEMENT)
			else:
				set_cellv(Vector2(x, y), Pawn.CELL_TYPES.ILLEGAL_PLACEMENT)
			
				
func get_cell_pawn(coordinates):
	for node in get_children():
		if world_to_map(node.position) == coordinates:
			return(node)


func request_move(pawn, new_position, final=false):
	var cell_start = world_to_map(pawn.position)
	var cell_target = world_to_map(new_position)
	var cell_target_type = get_cellv(cell_target)
	
	match cell_target_type:
		EMPTY:
			if final:
				return update_pawn_position(pawn, cell_start, cell_target)
			else:
				return get_world_position(cell_target)
		OBJECT:
			if final:
				var object_pawn = get_cell_pawn(cell_target)
				object_pawn.queue_free()
				return update_pawn_position(pawn, cell_start, cell_target)
			else:
				return get_world_position(cell_target)

		ACTOR:
#			var pawn_name = get_cell_pawn(cell_target).name
#			print("Cell %s contains %s" % [cell_target, pawn_name])
			pass

func update_pawn_position(pawn, cell_start, cell_target):
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, EMPTY)
	return get_world_position(cell_target)
	
func get_world_position(cell_target):
	return map_to_world(cell_target) + cell_size / 2
	
func _on_GamePiece_dropped(actor, new_location) -> void:
	var potential_location = request_move(actor, new_location)
	if potential_location:
		actor.move(potential_location)
	else:
		print("Can't go there!")

func _on_GamePiece_dragged(actor, new_location) -> void:
	var potential_location = request_move(actor, new_location)
	if potential_location:
		actor.potential_move(potential_location)
	else:
		print("Can't go there!")
