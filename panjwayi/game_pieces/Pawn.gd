extends Node2D
class_name Pawn

"""
A Pawn is any object that can be placed on a gameboard tile
i.e. a gameboard piece

"""

enum CELL_TYPES{ ACTOR, OBSTACLE, OBJECT }
export(CELL_TYPES) var type = CELL_TYPES.ACTOR

export(Texture) var sprite
