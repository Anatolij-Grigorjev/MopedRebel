extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG

const PROPS_FILES = [

]

func _ready():
	LOG = Logger.new('L')
	
	LOG.info("Loaded %s global resources: %s!", [PROPS_FILES.size(), PROPS_FILES])
	pass
