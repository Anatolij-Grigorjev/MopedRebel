extends StaticBody2D

var LOG = preload("res://globals/logger.gd").new(self)

onready var anim = $anim
var crash_position = Vector2()

func _ready():
	LOG.info("setting crash animation at %s", [crash_position])
	#fix position animation to current global
	var animation = anim.get_animation("entry")
	var position_track_idx = animation.find_track(NodePath(".:position"))
	
	var key_start_idx = animation.track_find_key(position_track_idx, 0.0)
	var key_end_idx = animation.track_find_key(position_track_idx, 0.5)
	
	animation.track_set_key_value(position_track_idx, key_start_idx, crash_position)
	animation.track_set_key_value(position_track_idx, key_end_idx, crash_position - Vector2(50, 0))	

