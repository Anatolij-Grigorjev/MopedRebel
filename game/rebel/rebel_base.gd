extends KinematicBody2D

signal finish_mount_moped
signal finish_unmount_moped(sidewalk_position)
signal started_jumping_curb(new_road_type)
signal changed_facing(new_facing)
signal started_conflict_with(enemy_node)
signal escaped_conflict

var Logger = preload("res://globals/logger.gd")
var LOG

var TallyText = preload("res://common/tally_text.tscn")

var low_position
var camera
var active_sprite

var facing_direction = C.FACING.RIGHT
var velocity = Vector2()

var enabled = true
var control_locked = false

func _ready():
	active_sprite = $sprite
	low_position = $low_collider
	camera = $camera
	S.connect_signal_to(S.SIGNAL_ENEMY_SCARED, $shout_maker, '_shout_at_enemy')
	S.connect_signal_to(S.SIGNAL_ENEMY_DISSED, $shout_maker, '_shout_at_enemy')
	
	
func disable():
	if (enabled):
		_disable_collision_layers()
		set_physics_process(false)
		visible = false
		enabled = false
		camera.clear_current()
		LOG.info("DISABLE")
		
func _disable_collision_layers():
	LOG.error("_disable_collision_layers not implemented in caller rebel!")
	
func enable():
	if (not enabled):
		_enable_collision_layers()
		set_physics_process(true)
		visible = true
		enabled = true
		camera.make_current()
		LOG.info("ENABLE")

func _enable_collision_layers():
	LOG.error("_enable_collision_layers not implemented in caller rebel!")
		
func lock_control():
	control_locked = true
	
func unlock_control():
	control_locked = false
	
func play_nointerrupt_anim(anim_name):
	var animation = $anim.get_animation(anim_name)
	F.assert_not_null(animation)
	if (not F.is_anim_playing($anim, anim_name)):
		lock_control()
		F.invoke_later(self, 'unlock_control', animation.length)
		$anim.play(anim_name)
		

	
