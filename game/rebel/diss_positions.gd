extends Node2D

var diss_action_direction_to_pos_node = {}
var diss_action_direction_to_node_angle = {}
var active_diss_position_node
var active_diss_zone_angle

func _ready():
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

func _process(delta):
	for diss_action_direction in diss_action_direction_to_pos_node:
		if (Input.is_action_pressed(diss_action_direction)):
			active_diss_position_node = diss_action_direction_to_pos_node[diss_action_direction]
			active_diss_zone_angle = diss_action_direction_to_node_angle[diss_action_direction]
