extends TileMap
class_name PanjwayiTileMap

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT}

const BOARD_SIZE = Vector2(16, 16)
const BOARD_OFFSET = Vector2(398, 0)

onready var movement_highlight = load("res://scenes/game/grid/MovementHighlight.tscn")
onready var attack_highlight = load("res://scenes/game/grid/AttackHighlight.tscn")

signal piece_destroyed(actor)
signal piece_attacked(actor)
signal village_captured(village)

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

			
#func _set_grid_contents(actor: Actor, cell: Vector2):
#	grid_contents[cell.x][cell.y] = actor

func _init_villages() -> void:
	var villages = get_tree().get_nodes_in_group("villages")
	for village in villages:
		var cell = world_to_map(village.position)
		if get_cellv(cell) == Pawn.CELL_TYPES.ACTOR:
			set_cellv(cell, Pawn.CELL_TYPES.OCCUPIED_VILLAGE)
			print("Occupied Village at: ", cell)
		else:
			print("Empty Village at cell: ", cell)
			set_cellv(cell, Pawn.CELL_TYPES.VILLAGE)
				
func prepare_board_for_game_start():
	_init_villages()
	for x in BOARD_SIZE.x:
		for y in BOARD_SIZE.y:
			var cell = get_cell(x, y)
			if cell != Pawn.CELL_TYPES.ACTOR and cell != Pawn.CELL_TYPES.VILLAGE and cell != Pawn.CELL_TYPES.OCCUPIED_VILLAGE:
				set_cell(x, y, Pawn.CELL_TYPES.OPEN)
			else:
				print(x, ", ",y, ": ", get_cell(x, y))


func get_cell_highlight(coordinates):
	for node in get_children():
		if node.is_in_group("indicators") and world_to_map(node.position) == coordinates:
			return(node)

func request_move(actor: Actor, new_position, final=false, force=false):
	var cell_start = world_to_map(actor.position)
	var cell_target = world_to_map(new_position)
	var cell_target_type = get_cellv(cell_target)
	
	if cell_start == cell_target:
		# hasn't moved yet
		return null
		
	if force:
		return update_pawn_position(actor, cell_start, cell_target)
	
	match cell_target_type:
		Pawn.CELL_TYPES.CAN_ATTACK:
			if final:
				if is_actor(cell_target): # could also be a village
					var destroyed_actor: Actor = get_actor(cell_target)
					remove_child(destroyed_actor)
					emit_signal("piece_destroyed", destroyed_actor)
				# Actually moving the actor there:
				if is_village(cell_target):
					# handle village occupation!
					emit_signal("village_captured", get_village(cell_target))
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
	if get_cellv(cell_target) != Pawn.CELL_TYPES.OCCUPIED_VILLAGE:
		set_cellv(cell_target, actor.type)
	# otherwise leave it as an occupied village type
	
	# check if they are moving out of a village
	if get_cellv(cell_start) == Pawn.CELL_TYPES.OCCUPIED_VILLAGE:
		set_cellv(cell_start, Pawn.CELL_TYPES.VILLAGE)
	else:
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
					_set_cell_moveable(valid_move_cell)
					
				if cell_type == Pawn.CELL_TYPES.VILLAGE:
					var village_at_cell = get_village(valid_move_cell)
					print("FOUND A VILLAGE")
					print(valid_move_cell)
					print(village_at_cell.team)
					print(actor.team)
					if village_at_cell.team != actor.team and actor.captures_villages:
						_set_cell_attackable(valid_move_cell)
					else:
						_set_cell_moveable(valid_move_cell)
					
				elif cell_type == Pawn.CELL_TYPES.ACTOR or cell_type == Pawn.CELL_TYPES.OCCUPIED_VILLAGE:
					# cell has another actor, check what kind of actor to see if we can attack it
					var actor_at_cell: Actor = get_actor(valid_move_cell)
					# if actor type is in the attackable_unit Array
					if actor.attackable_units.find(actor_at_cell.actor_type) != -1:
						_set_cell_attackable(valid_move_cell)
					elif actor.pass_overable_units.find(actor_at_cell.actor_type) == -1:
						# Not in the pass overable list, so this should block movement too
						set_cellv(valid_move_cell, Pawn.CELL_TYPES.MOVEMENT_BLOCKING_ACTOR)

	# at the end we'll remove movement beyond blocking elements		
	_remove_move_cells_beyond_blocked(actor)

func _set_cell_moveable(cell):
	var highlight = movement_highlight.instance()
	highlight.position = get_world_position(cell)
	set_cellv(cell, Pawn.CELL_TYPES.CAN_MOVE_TO)
	add_child(highlight)
	
func _set_cell_attackable(cell):
	# Highlight cell as attackable
	var highlight = attack_highlight.instance()
	highlight.position = get_world_position(cell)
	set_cellv(cell, Pawn.CELL_TYPES.CAN_ATTACK)
	add_child(highlight)
	
func _remove_move_cells_beyond_blocked(actor):
	var actor_cell = world_to_map(actor.position)
	var blocking_cells = get_used_cells_by_id(Pawn.CELL_TYPES.CAN_ATTACK)
	for blocking_cell in blocking_cells: 
		_remove_movement_beyond_cell(actor_cell, blocking_cell)
	blocking_cells = get_used_cells_by_id(Pawn.CELL_TYPES.MOVEMENT_BLOCKING_ACTOR)
	for blocking_cell in blocking_cells: 
		_remove_movement_beyond_cell(actor_cell, blocking_cell)

func _remove_movement_beyond_cell(origin_cell: Vector2, blocking_cell: Vector2):
	""" Removes all cells as moveable locations that are beyond a specific blocking cell
	This assumes straight movement on a square grid, so movement only in 8 directions.
	"""
	var blocked_cell: Vector2 # the cell that is blocked by an obstacle

	# Generate a "ray" that extends from the origin_cell to the blocking cell
	var ray: Vector2 = blocking_cell - origin_cell
	
	# increment the cell in the direction of blocking cell and remove movement
	for i in range(BOARD_SIZE.x):  # this is overkill, should limit to x,y > (0,0)
		if ray.y < 0 :  # The attack spot is to north 
			ray.y -= 1
		elif ray.y > 0:  # to the south
			ray.y += 1
		if ray.x < 0:  # to the left
			ray.x -= 1
		elif ray.x > 0:  # to the right
			ray.x += 1
		blocked_cell = origin_cell + ray
		if get_cellv(blocked_cell) == Pawn.CELL_TYPES.CAN_MOVE_TO or Pawn.CELL_TYPES.CAN_ATTACK:
			_clear_movement_in_cell(blocked_cell)

func get_actor(cell: Vector2) -> Actor:
	""" Returns the Actor in the cell
	"""
	return _get_node_in_group(cell, "actors") as Actor
	
func get_village(cell: Vector2) -> Village:
	""" Returns the Actor in the cell
	"""
	return _get_node_in_group(cell, "villages") as Village

func _get_node_in_group(cell: Vector2, group: String) -> Node2D:
	""" Returns the item in the cell and group
	"""
	var nodes = get_tree().get_nodes_in_group(group)
	for node in nodes:
		if cell == world_to_map(node.position):
			return node	
	return null	
	
func is_village(cell: Vector2) -> bool:
	return _get_node_in_group(cell, "villages") != null
	
func is_actor(cell: Vector2) -> bool:
	return _get_node_in_group(cell, "actors") != null

func clear_movement():
	get_tree().call_group("map_indicators", "queue_free")
	for x in BOARD_SIZE.x:
		for y in BOARD_SIZE.y:
			_clear_movement_in_cell(Vector2(x, y))
				
func _clear_movement_in_cell(cell: Vector2):
	var indicator = _get_node_in_group(cell, "map_indicators")
	if indicator != null:
		indicator.queue_free()
	var cell_type = get_cellv(cell)
	if cell_type == Pawn.CELL_TYPES.CAN_MOVE_TO:
		set_cellv(cell, Pawn.CELL_TYPES.OPEN)
	elif cell_type == Pawn.CELL_TYPES.CAN_ATTACK:
		set_cellv(cell, Pawn.CELL_TYPES.ACTOR)	
	elif cell_type == Pawn.CELL_TYPES.MOVEMENT_BLOCKING_ACTOR:
		set_cellv(cell, Pawn.CELL_TYPES.ACTOR)
				
