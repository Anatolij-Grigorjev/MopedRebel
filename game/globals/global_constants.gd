extends Node

## GAME
enum FACING {
	RIGHT = 1,
	LEFT = -1
}
const Z_COEF = sin(deg2rad(45))
const GRAVITY = 98.5
const DOUBLE_TAP_LIMIT = 0.25
#lowest in-game point
const MAX_WORLD_Y = 100000

const GUI_SELECTED_OPT_MARKER = "->"
const DISS_JSON_LOCATION = "res://conflict/dissing/disses.json"

## LAYERS
const LAYERS_SIDEWALK = 0
const LAYERS_CURB = 1
const LAYERS_ROAD = 2
const LAYERS_REBEL_SIDEWALK = 3
const LAYERS_REBEL_ROAD = 4
const LAYERS_TRANSPORT_ROAD = 5

## GROUPS
const GROUP_CARS = "road_cars"
const GROUP_CITIZENS = "sidewalk_citizens"


const DATETIME_FORMAT = "%s.%s.%s %s:%s:%s"


func _ready():
	print("Loaded global constants node C!")
	pass
