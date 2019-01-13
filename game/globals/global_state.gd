extends Node

#global state node, stubbed props for testing individual scenes
var node_rebel_on_foot = {
	"global_position": Vector2()
}
var node_rebel_on_moped = {
	"global_position": Vector2()
}
var moped_config_max_speed = 150
var moped_config_min_speed = 50
var moped_config_acceleration_rate = 5
var moped_config_swerve_speed = F.y2z(moped_config_max_speed)
var moped_config_swerve_acceleration_rate = 15
var moped_config_swerve_neutral_threshold = (moped_config_swerve_acceleration_rate / 2)

func _ready():
	print("Loaded global game state node G!")
	pass