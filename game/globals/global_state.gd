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
var moped_config_swerve_acceleration_rate = F.y2z(moped_config_max_acceleration_rate)
var moped_config_crash_recovery_time = 0.9
var moped_config_max_flat_velocity_sq = Vector2(
	moped_config_max_speed,
	moped_config_swerve_speed
).length_squared()

func _ready():
	print("Loaded global game state node G!")
	print('moped_config_max_speed: %s' % moped_config_max_speed)
	print('moped_config_min_speed: %s' % moped_config_min_speed)
	print('moped_config_max_acceleration_reach_time: %s' % moped_config_max_acceleration_reach_time)
	print('moped_config_max_acceleration_rate: %s' % moped_config_max_acceleration_rate)
	print('moped_config_brake_intensity: %s' % moped_config_brake_intensity)
	print('moped_config_swerve_speed: %s' % moped_config_swerve_speed)
	print('moped_config_swerve_acceleration_rate: %s' % moped_config_swerve_acceleration_rate)
	print('moped_config_crash_recovery_time: %s' % moped_config_crash_recovery_time)
	print('moped_config_max_flat_velocity_sq: %s' % moped_config_max_flat_velocity_sq)
	pass