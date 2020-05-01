extends Node2D
class_name Pawn

"""
A Pawn is any object or that can be placed on a gameboard tile
Including dummy objects to hold the status of a tile
i.e. a gameboard piece

"""

enum CELL_TYPES { 
	ACTOR, OBSTACLE, OBJECT,  
	LEGAL_GOA_PLACEMENT, LEGAL_TALIBAN_PLACEMENT, ILLEGAL_PLACEMENT,
	OPEN
}
export(CELL_TYPES) var type = CELL_TYPES.ACTOR

export(Texture) var sprite
