extends Node

## GAME
const Z_COEF = sin(deg2rad(45))
const GRAVITY = 98.5
#lowest in-game point
const MAX_WORLD_Y = 100000

## LAYERS
const LAYERS_SIDEWALK = 0
const LAYERS_CURB = 1
const LAYERS_ROAD = 2


const DATETIME_FORMAT = "%s.%s.%s %s:%s:%s"


func _ready():
	print("Loaded global constants node C!")
	pass
