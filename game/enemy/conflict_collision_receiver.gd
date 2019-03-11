extends Node2D

var LOG = preload("res://globals/logger.gd").new(self)

var collided = false

var bribe_money
var min_diss_sc
var enemy_toughness

var pre_collide_action_node
var pre_collide_action_name

func _ready():
	pass
	
func set_pre_conflict_collision_action(action_owner_node, action_name):
	self.pre_collide_action_node = action_owner_node
	self.pre_collide_action_name = action_name

func set_conflict_params(bribe_money, min_diss_sc, enemy_toughness):
	self.bribe_money = bribe_money 
	self.min_diss_sc = min_diss_sc
	self.enemy_toughness = enemy_toughness

func react_collision(collision):
	if (not collided and _collision_is_rebel(collision)):
		LOG.info("fresh collision with %s", [collision.collider])
		collided = true
		if (pre_collide_action_node != null and pre_collide_action_name != null):
			pre_collide_action_node.call(pre_collide_action_name)
		S.emit_signal(S.SIGNAL_REBEL_START_CONFLICT,
			owner,
			bribe_money,
			min_diss_sc,
			enemy_toughness
		)
		
func reset_collision():
	collided = false
	
func _collision_is_rebel(collision):
	return (
		collision.collider == G.node_rebel_on_foot or
		collision.collider == G.node_rebel_on_moped
	)