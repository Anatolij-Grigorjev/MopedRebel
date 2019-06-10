extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG
var ShoutPopup = preload("res://common/shout_popup.tscn")

func _ready():
	pass
	
func _turn_around_offscreen_rebel(rebel_facing):
	LOG.info('rebel went offscreen long enough, turning around...')
	
	var rebel_node = G.node_active_rebel
	rebel_node.control_locked = true
	
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
	var manager_line = PE.get_specific_manager_phrase(C.MANAGER_PHRASE_EXIT_STAGE_START)
	_show_shout_dialog(manager_line, time_back)
	
func _show_shout_dialog(shout_line, for_seconds):
	var shout_dialog = ShoutPopup.instance()
	shout_dialog.shout_line = shout_line
	shout_dialog.visible_time = for_seconds
	add_child(shout_dialog)
	shout_dialog.show_popup()

func _restore_rebel_control():
	G.node_active_rebel.control_locked = false
