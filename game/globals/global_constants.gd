extends Node

## GAME
const Z_COEF = sin(deg2rad(45))
const GRAVITY = 98.5

## LAYERS
const LAYERS_SIDEWALK = 0
const LAYERS_CURB = 1
const LAYERS_ROAD = 2


const DATETIME_FORMAT = "%s.%s.%s %s:%s:%s"

const MIN_MOPED_SPEED = 100
const MAX_MOPED_SPEED = 550
const MOPED_ACCELERATION_RATE = 35
const MOPED_Z_SPEED = 20


func _ready():
	print("Loaded global constants node C!")
	pass
