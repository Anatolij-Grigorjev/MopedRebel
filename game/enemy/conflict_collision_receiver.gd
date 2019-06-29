extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG

signal collided_with_rebel(collision_obj)

#INTERNAL VARS
var collided = false

func _ready():
	LOG = Logger.new(self)
	#configure logger to ouput owner name and this as type
	LOG.entity_name = "[" + F.get_node_name_safe(owner)
	LOG.entity_type_descriptor = "|conflict-recv]"
	pass

func react_collision(collision):
	if (not collided and _collided_with_me_or_rebel(collision)):
		LOG.info("fresh collision with %s", [collision.collider])
		collided = true
		emit_signal("collided_with_rebel", collision)
		
func reset_collision():
	collided = false
	
func _collided_with_me_or_rebel(collision):
	return collision.collider in [owner, G.node_active_rebel]
	