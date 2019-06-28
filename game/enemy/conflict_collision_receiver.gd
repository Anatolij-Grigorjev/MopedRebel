extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG

export(float) var bribe_money
export(float) var min_diss_sc
export(String) var enemy_toughness

signal about_to_collide(collision)

#INTERNAL VARS
var collided = false

func _ready():
	LOG = Logger.new(self)
	#configure logger to ouput owner name and this as type
	LOG.entity_name = "[" + owner.name
	LOG.entity_type_descriptor = "|conflict-recv]"
	pass

func set_conflict_params(bribe_money, min_diss_sc, enemy_toughness):
	self.bribe_money = bribe_money 
	self.min_diss_sc = min_diss_sc
	self.enemy_toughness = enemy_toughness

func react_collision(collision):
	if (not collided and _collided_with_me_or_rebel(collision)):
		emit_signal('about_to_collide', collision)
		LOG.info("fresh collision with %s", [collision.collider])
		collided = true
		S.emit_signal4(S.SIGNAL_REBEL_START_CONFLICT,
			owner,
			bribe_money,
			min_diss_sc,
			enemy_toughness
		)
		
func reset_collision():
	collided = false
	
func _collided_with_me_or_rebel(collision):
	return (
		collision.collider == owner or
		F.is_node_rebel(collision.collider)
	)