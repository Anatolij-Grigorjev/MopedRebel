extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG
var ShoutPopup = preload("res://common/shout_popup.tscn")

func _ready():
	pass
	
func _body_left_screen_headed_left(body):
	if (F.is_body_active_rebel(body)
		and G.node_active_rebel.facing_direction == C.FACING.LEFT):
		_turn_around_offscreen_rebel(G.node_active_rebel.facing_direction)

	
func _turn_around_offscreen_rebel(rebel_facing):
	LOG.info('rebel went offscreen long enough, turning around...')
	
	var rebel_node = G.node_active_rebel
	rebel_node.lock_control()
	
	#which direction rebel should face to comeback onscreen
	var new_facing = F.flip_facing(rebel_facing)
	
	#turn around rebel on moped in case its still facing wrong way
	if (F.is_rebel_state(C.REBEL_STATES.ON_MOPED)
		and rebel_node.facing_direction != new_facing):
		rebel_node._turn_around_moped()
		
	var comeback_speed = 0
	if (F.is_rebel_state(C.REBEL_STATES.ON_MOPED)):
		var average_moped_speed = G.moped_config_min_speed + ((G.moped_config_max_speed - G.moped_config_min_speed) / 2)
		rebel_node.current_speed = average_moped_speed
		comeback_speed = average_moped_speed
	else:
		var walk_speed = G.foot_config_walk_speed
		rebel_node.velocity = Vector2(walk_speed * new_facing, 0)
		comeback_speed = walk_speed
	#amount of time it will take to drive back
	var time_back = (100 + abs(rebel_node.global_position.x)) / comeback_speed
	#give back control once onscreen
	F.invoke_later(self, '_restore_rebel_control', time_back)
	#make manager shout
	var manager_line = 'Get back to it, MR, delivery ain\'t done yet!'
	$shout_maker.shout_for_seconds(manager_line)

func _restore_rebel_control():
	G.node_active_rebel.unlock_control()
