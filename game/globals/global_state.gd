extends Node

var Logger = preload("res://globals/logger.gd")
var LOG

#global state node, stubbed props for testing individual scenes

###GENERAL REBEL STATE###
var rebel_total_street_cred = 50
var rebel_total_money = 200.7
########
##FOOT##
########
var node_rebel_on_foot 
var foot_config_walk_speed = 150

#########
##MOPED##
#########
var node_rebel_on_moped 
var node_active_rebel = {}
var active_rebel_state = C.REBEL_STATES.ON_FOOT
var node_current_stage_root = {}
var moped_config_max_speed = 400
var moped_config_min_speed = 10
var moped_config_max_acceleration_reach_time = 3.5
var moped_config_max_acceleration_rate = 45
var moped_config_brake_intensity = 50
var moped_config_swerve_speed = F.y2z(moped_config_max_speed)
var moped_config_swerve_acceleration_rate = F.y2z(moped_config_max_acceleration_rate)
var moped_config_max_flat_velocity_sq = Vector2(
	moped_config_max_speed,
	moped_config_swerve_speed
).length_squared()


var PRESSED_ACTIONS_TRACKER = {}

func _ready():
	LOG = Logger.new('G')
	LOG.info("Loaded global game state node G!")
	LOG.info('moped_config_max_speed: %s' % moped_config_max_speed)
	LOG.info('moped_config_min_speed: %s' % moped_config_min_speed)
	LOG.info('moped_config_max_acceleration_reach_time: %s' % moped_config_max_acceleration_reach_time)
	LOG.info('moped_config_max_acceleration_rate: %s' % moped_config_max_acceleration_rate)
	LOG.info('moped_config_brake_intensity: %s' % moped_config_brake_intensity)
	LOG.info('moped_config_swerve_speed: %s' % moped_config_swerve_speed)
	LOG.info('moped_config_swerve_acceleration_rate: %s' % moped_config_swerve_acceleration_rate)
	LOG.info('moped_config_max_flat_velocity_sq: %s' % moped_config_max_flat_velocity_sq)
	PRESSED_ACTIONS_TRACKER.clear()
	pass
	
func track_action_press_release(action_name):
	stop_tracking_action_press_release(action_name)
	PRESSED_ACTIONS_TRACKER[action_name] = {
		'last_pressed_time': 0,
		'last_released_time': 0
	}
	
func stop_tracking_action_press_release(action_name):
	if (PRESSED_ACTIONS_TRACKER.has(action_name)):
		PRESSED_ACTIONS_TRACKER.erase(action_name)
		
func _process(delta):
	for action_name in PRESSED_ACTIONS_TRACKER:
		if (Input.is_action_just_pressed(action_name)):
			PRESSED_ACTIONS_TRACKER[action_name].last_pressed_time = 0
		elif (Input.is_action_just_released(action_name)):
			PRESSED_ACTIONS_TRACKER[action_name].last_released_time = 0
		else:
			if (Input.is_action_pressed(action_name)):
				PRESSED_ACTIONS_TRACKER[action_name].last_pressed_time += delta
			else:
				PRESSED_ACTIONS_TRACKER[action_name].last_released_time += delta
			