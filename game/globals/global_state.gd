extends Node

#global state node, stubbed props for testing individual scenes

########
##FOOT##
########
var node_rebel_on_foot = {
	"global_position": Vector2()
}
var foot_config_walk_speed = 50

#########
##MOPED##
#########
var node_rebel_on_moped = {
	"global_position": Vector2()
}
var node_active_rebel = {}
var node_current_stage_root = {}
var moped_config_max_speed = 200
var moped_config_min_speed = 10
var moped_config_max_acceleration_reach_time = 3.5
var moped_config_max_acceleration_rate = 45
var moped_config_brake_intensity = 50
var moped_config_swerve_speed = F.y2z(moped_config_max_speed)
var moped_config_swerve_acceleration_rate = 15
var moped_config_swerve_neutral_threshold = (moped_config_swerve_acceleration_rate / 2)
var moped_config_crash_recovery_time = 0.9

func _ready():
	print("Loaded global game state node G!")
	pass