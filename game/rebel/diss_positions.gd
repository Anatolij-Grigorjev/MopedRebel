extends Node2D

var diss_action_direction_to_pos_node = {}
var active_diss_position_node

func _ready():
	diss_action_direction_to_pos_node = {
		"diss_left": $diss_left_position,
		"diss_right": $diss_right_position,
		"diss_up": $diss_up_position,
		"diss_down": $diss_down_position
	}

func _process(delta):
	for diss_action_direction in diss_action_direction_to_pos_node:
		if (Input.is_action_pressed(diss_action_direction)):
			active_diss_position_node = diss_action_direction_to_pos_node[diss_action_direction]
