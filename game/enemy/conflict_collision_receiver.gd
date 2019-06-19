extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG

export(NodePath) var pre_collide_action_node_path
export(String) var pre_collide_action_name
export(float) var bribe_money
export(float) var min_diss_sc
export(String) var enemy_toughness


#INTERNAL VARS
var collided = false
var pre_collide_action_node

func _ready():
	LOG = Logger.new(self)
	#configure logger to ouput owner name and this as type
	LOG.entity_name = owner.name
	LOG.entity_type_descriptor = "[conflict-recv]"
	pre_collide_action_node = get_node(pre_collide_action_node_path)
	pass
	
func set_pre_conflict_collision_action(action_owner_node, action_name):
	self.pre_collide_action_node = action_owner_node
	self.pre_collide_action_name = action_name

func set_conflict_params(bribe_money, min_diss_sc, enemy_toughness):
	self.bribe_money = bribe_money 
	self.min_diss_sc = min_diss_sc
	self.enemy_toughness = enemy_toughness
	

func react_collision(collision):
	if (not collided and _collided_with_me_or_rebel(collision)):
		LOG.info("fresh collision with %s", [collision.collider])
		collided = true
		call_pre_collision_action()
		S.emit_signal(S.SIGNAL_REBEL_START_CONFLICT,
			owner,
			bribe_money,
			min_diss_sc,
			enemy_toughness
		)
		
func reset_collision():
	collided = false
	
func call_pre_collision_action():
	if (pre_collide_action_node != null and pre_collide_action_name != null):
		pre_collide_action_node.call(pre_collide_action_name)
	
func _collided_with_me_or_rebel(collision):
	return (
		collision.collider == owner or
		F.is_node_rebel(collision.collider)
	)