extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT}

func _ready():
	for child in get_children():
		set_cellv(world_to_map(child.position), child.type)
		
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
