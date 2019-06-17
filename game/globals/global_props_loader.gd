extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG

var loaded_enemies_props = {}

func _ready():
	LOG = Logger.new('L')
	
	loaded_enemies_props = F.parse_json_file_as_var(C.ENEMY_PROPS_JSON_LOCATION)
	LOG.info("Loaded props for %s enemy types!", [loaded_enemies_props.size()])
	
	pass
