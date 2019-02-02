extends Node

## GAME
enum FACING {
	RIGHT = 1,
	LEFT = -1
}
const Z_COEF = sin(deg2rad(45))
const GRAVITY = 98.5
#lowest in-game point
const MAX_WORLD_Y = 100000

const GUI_SELECTED_OPT_MARKER = "->"

## LAYERS
const LAYERS_SIDEWALK = 0
const LAYERS_CURB = 1
const LAYERS_ROAD = 2

## GROUPS
const GROUP_CARS = "road_cars"


const DATETIME_FORMAT = "%s.%s.%s %s:%s:%s"


func _ready():
	print("Loaded global constants node C!")
	pass
