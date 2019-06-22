extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG

var diss_action_direction_to_pos_node = {}
var diss_action_direction_to_node_angle = {}
var active_diss_position_node
var active_diss_zone_angle

func _ready():
	LOG = Logger.new("")
	#configure logger to ouput owner name and this as type
	LOG.entity_name = "[" + owner.name
	LOG.entity_type_descriptor = "|diss-pos]"
	
	update_for_facing(C.FACING.RIGHT)
	_assign_new_diss_direction("diss_right")

func _process(delta):
	for diss_action_direction in diss_action_direction_to_pos_node:
		if (Input.is_action_pressed(diss_action_direction)):
			_assign_new_diss_direction(diss_action_direction)

func _assign_new_diss_direction(diss_action_direction):
	var prev_active_diss_pos = active_diss_position_node
	active_diss_position_node = diss_action_direction_to_pos_node[diss_action_direction]
	active_diss_zone_angle = diss_action_direction_to_node_angle[diss_action_direction]
	
func update_for_facing(facing):
	if (facing == C.FACING.RIGHT):
		diss_action_direction_to_pos_node = {
				"diss_left": $diss_left_position,
				"diss_right": $diss_right_position,
				"diss_up": $diss_up_position,
				"diss_down": $diss_down_position
			}
		diss_action_direction_to_node_angle = {
				"diss_left": 180,
				"diss_right": 0,
				"diss_up": 270,
				"diss_down": 90
			}
	else:
		diss_action_direction_to_pos_node =  {
				"diss_left": $diss_right_position,
				"diss_right": $diss_left_position,
				"diss_up": $diss_up_position,
				"diss_down": $diss_down_position
			}
		diss_action_direction_to_node_angle = {
				"diss_left": 0,
				"diss_right": 180,
				"diss_up": 270,
				"diss_down": 90
			}
