extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG

var DissZone = preload("res://rebel/dissing_zone.tscn")
var active_dissing_zone

var diss_action_direction_to_pos_node = {}
var diss_action_direction_to_node_angle = {}
var active_diss_position_node
var active_diss_zone_angle

func _ready():
	LOG = F.configure_sub_logger(Logger.new(""), owner, "diss-pos")
	update_for_facing(C.FACING.RIGHT)
	_assign_new_diss_direction("diss_right")

func _process(delta):
	for diss_action_direction in diss_action_direction_to_pos_node:
		if (Input.is_action_pressed(diss_action_direction)):
			_assign_new_diss_direction(diss_action_direction)
	_process_dissing_zone()


func _process_dissing_zone():
	if Input.is_action_pressed('flip_bird'):
		if (active_dissing_zone == null):
			active_dissing_zone = DissZone.instance()
			add_child(active_dissing_zone)
		_set_dissing_zone_position()
	else:
		if (active_dissing_zone != null):
			active_dissing_zone.clear_present_nodes()
			active_dissing_zone.queue_free()
			active_dissing_zone = null

func _set_dissing_zone_position():
	var active_position_node = active_diss_position_node
	if (active_position_node != null):
		active_dissing_zone.global_position = active_position_node.global_position
		active_dissing_zone.rotation_degrees = active_diss_zone_angle

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
