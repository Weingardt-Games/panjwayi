extends Node2D
class_name Pawn

"""
A Pawn is any object or that can be placed on a gameboard tile
Including dummy objects to hold the status of a tile
i.e. a gameboard piece

"""
# Might not need TEAM, can use groups instead
enum TEAM{ NONE, GOA, TALIBAN }
export(TEAM) var team = TEAM.NONE

enum CELL_TYPES {
	ACTOR, VILLAGE, OCCUPIED_VILLAGE,
	LEGAL_PLACEMENT, NOT_USED, ILLEGAL_PLACEMENT,
	OPEN,
	CAN_MOVE_TO, CAN_ATTACK, MOVEMENT_BLOCKING_ACTOR
}
export(CELL_TYPES) var type = CELL_TYPES.ACTOR

export(Texture) var sprite
