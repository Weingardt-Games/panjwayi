extends TileMap
class_name PanjwayiTileMap

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT}

const BOARD_SIZE = Vector2(16, 16)
const BOARD_OFFSET = Vector2(398, 0)

onready var movement_highlight = load("res://scenes/game/grid/MovementHighlight.tscn")
onready var attack_highlight = load("res://scenes/game/grid/AttackHighlight.tscn")

signal piece_destroyed(actor)

func _ready():
	# Fill the TileMap Grid with PLACEMENT_CELL_TYPES
	for x in BOARD_SIZE.x:
		for y in BOARD_SIZE.y:
			if y < 4:
				set_cell(x, y, Pawn.CELL_TYPES.LEGAL_GOA_PLACEMENT)
			elif y >= 12:
				set_cell(x, y, Pawn.CELL_TYPES.LEGAL_TALIBAN_PLACEMENT)
			else:
				set_cell(x, y, Pawn.CELL_TYPES.ILLEGAL_PLACEMENT)
				
func prepare_board_for_game_start():
	for x in BOARD_SIZE.x:
		for y in BOARD_SIZE.y:
			if get_cell(x, y) != Pawn.CELL_TYPES.ACTOR:
				set_cell(x, y, Pawn.CELL_TYPES.OPEN)

				
func get_cell_pawn(coordinates):
	for node in get_children():
		if world_to_map(node.position) == coordinates:
			return(node)


func request_move(actor: Actor, new_position, final=false):
	var cell_start = world_to_map(actor.position)
	var cell_target = world_to_map(new_position)
	var cell_target_type = get_cellv(cell_target)
	
	if cell_start == cell_target:
		# hasn't moved yet
		return get_world_position(cell_target)
	
	match cell_target_type:
		Pawn.CELL_TYPES.CAN_ATTACK:
			if final:
				var destroyed_actor: Actor = get_actor(cell_target)
				remove_child(destroyed_actor)
				emit_signal("piece_destroyed", destroyed_actor)
				# Actually moving the actor there:
				return update_pawn_position(actor, cell_start, cell_target)
			else:
				# Just checking if we can move there...
				return get_world_position(cell_target)
		Actor.CELL_TYPES.CAN_MOVE_TO:
			if final:
				# Actually moving the actor there
				return update_pawn_position(actor, cell_start, cell_target)
			else:
				# Just checking if we can move there...
				return get_world_position(cell_target)
#		OBJECT:
#			if final:
#				var object_pawn = get_cell_pawn(cell_target)
#				object_pawn.queue_free()
#				return update_pawn_position(pawn, cell_start, cell_target)
#			else:
#				return get_world_position(cell_target)
#		ACTOR:
##			var pawn_name = get_cell_pawn(cell_target).name
##			print("Cell %s contains %s" % [cell_target, pawn_name])
#			pass

func update_pawn_position(actor: Actor, cell_start, cell_target):
	set_cellv(cell_target, actor.type)
	set_cellv(cell_start, Pawn.CELL_TYPES.OPEN)
	return get_world_position(cell_target)
	
func get_world_position(cell_target):
	return map_to_world(cell_target) + cell_size / 2
	
#### INDICATORS / HIGLIGHTS

func prep_movement(actor: Actor):
	""" Highlights the legal movement locations and sets their cell type
	to Pawn.CELL_TYPES.CAN_MOVE_TO,  and indicates potential attacks and 
	sets cell type to Pawn.CELL_TYPES.CAN_ATTACK
	"""
	# clear previous highlights:
	get_tree().call_group("map_indicators", "queue_free")
	var cell = world_to_map(actor.position)
	var move_array = actor.get_movement_array()
	var offset = Vector2(int(len(move_array)/2), int(len(move_array)/2))
	var max_distance = len(move_array)
	
	for y in max_distance:
		for x in max_distance:
			if move_array[x][y] == 1:
				var valid_move_cell = cell + Vector2(x, y) - offset
				var cell_type = get_cellv(valid_move_cell)
				
				if cell_type == Pawn.CELL_TYPES.OPEN:
					# cell is open, so highlight it as moveable spot
					var highlight = movement_highlight.instance()
					highlight.position = get_world_position(valid_move_cell)
					set_cellv(valid_move_cell, Pawn.CELL_TYPES.CAN_MOVE_TO)
					add_child(highlight)
					
				elif cell_type == Pawn.CELL_TYPES.ACTOR:
					# cell has another actor, check what kind of actor to see if we can attack it
					var actor_at_cell: Actor = get_actor(valid_move_cell)
					# if actor type is in the attackable_unit Array
					if actor.attackable_units.find(actor_at_cell.actor_type) != -1:
						# Highlight cell as attackable
						var highlight = attack_highlight.instance()
						highlight.position = get_world_position(valid_move_cell)
						set_cellv(valid_move_cell, Pawn.CELL_TYPES.CAN_ATTACK)
						add_child(highlight)

func get_actor(cell: Vector2) -> Actor:
	""" Returns the Actor in the cell
	"""
	var actors = get_tree().get_nodes_in_group("actors")
	for actor in actors:
		if cell == world_to_map(actor.position):
			return actor
	print("Something went wrong, there should be SOMEONE here!")
	return null

func clear_movement():
	get_tree().call_group("map_indicators", "queue_free")
	for x in BOARD_SIZE.x:
		for y in BOARD_SIZE.y:
			if get_cell(x, y) == Pawn.CELL_TYPES.CAN_MOVE_TO:
				set_cell(x, y, Pawn.CELL_TYPES.OPEN)
			elif get_cell(x,y) == Pawn.CELL_TYPES.CAN_ATTACK:
				set_cell(x, y, Pawn.CELL_TYPES.ACTOR)
				
