extends Node

const COLOR_MASK_R = int(pow(2, 24))
const COLOR_MASK_G = int(pow(2, 16))
const COLOR_MASK_B = int(pow(2, 8))
const COLOR_MASK_A = int(pow(2, 1))

## GAME
enum FACING {
	RIGHT = 1,
	LEFT = -1
}
enum REBEL_STATES {
	ON_FOOT = 0,
	ON_MOPED = 1
}
enum MOPED_GROUND_TYPES {
	ROAD = 0,
	SIDEWALK = 1
}
enum CONFLICT_RESOLUTIONS {
	BRIBE = 0,
	DISS = 1,
	FIGHT = 2
}
enum LOG_LEVELS {
	DEBUG = 0,
	INFO = 1,
	WARN = 2,
	ERROR = 3
}
enum INFO_TYPE {
	NEGATIVE = 255 * COLOR_MASK_R,
	INFO = 255 * COLOR_MASK_B,
	POSITIVE = 255 * COLOR_MASK_G
}
const Z_COEF = sin(deg2rad(45))
const GRAVITY = 98.5
const NUM_COLLISION_BITS = 20
const DOUBLE_TAP_LIMIT = 0.25
const CURRENT_LOG_LEVEL = LOG_LEVELS.INFO

#STAGES
const MAX_WORLD_Y = 100000
const GROUP_STAGE_CHUNK = "stage_chunk"
const GROUP_PROPS = "props"
const GROUP_CURB = "curb_tiles"

const GUI_SELECTED_OPT_MARKER = "->"
const GUI_AVAILABLE_OPTION_COLOR = Color(1, 1, 1)
const GUI_NOT_AVAILABLE_OPTION_COLOR = Color(0.5, 0.5, 0.5)
const GUI_REQ_NOT_MET_OPTION_COLOR = Color(1, 0, 0)
const ENEMY_PROPS_JSON_LOCATION = "res://enemy/type_properties.json"
const MANAGER_PHRASE_EXIT_STAGE_START = "leave_stage_start"

## LAYERS
const LAYERS_SIDEWALK = 0
const LAYERS_CURB = 1
const LAYERS_ROAD = 2
const LAYERS_REBEL_SIDEWALK = 3
const LAYERS_REBEL_ROAD = 4
const LAYERS_TRANSPORT_ROAD = 5

## ENEMY GROUPS
const GROUP_ENEMY = "enemy" #all enemies of moped rebel
const GROUP_CARS = "road_cars"
const GROUP_OBSTACLES = "road_obstacles"
const GROUP_CITIZENS = "sidewalk_citizens"
const GROUP_BENCHES = "benches"

const SC_GAIN_FOR_GROUP = {
	GROUP_CARS: 154,
	GROUP_CITIZENS: 57
}

const DATETIME_FORMAT = "%04d.%02d.%02d %02d:%02d:%02d"


func _ready():
	print("Loaded global constants node C!")
	pass
