extends KinematicBody2D

var Logger = preload("res://globals/logger.gd")
var LOG

var velocity = Vector2()
var dissing_zone_node_scene = preload("res://rebel/dissing_zone.tscn")
var active_dissing_zone

var diss_positions_control
var low_position
var camera
var active_sprite

var facing_direction = C.FACING.RIGHT

var enabled = true
var control_locked = false

func _ready():
	active_sprite = $sprite
	diss_positions_control = $diss_positions
	low_position = $low_collider
	camera = $camera
	
	
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
	
func _process_dissing_zone():
	if Input.is_action_pressed('flip_bird'):
		if (active_dissing_zone == null):
			active_dissing_zone = dissing_zone_node_scene.instance()
			add_child(active_dissing_zone)
		_set_dissing_zone_position()
	else:
		if (active_dissing_zone != null):
			active_dissing_zone.clear_present_nodes()
			active_dissing_zone.queue_free()
			active_dissing_zone = null

func _set_dissing_zone_position():
	var active_position_node = diss_positions_control.active_diss_position_node
	if (active_position_node != null):
		active_dissing_zone.global_position = active_position_node.global_position
		active_dissing_zone.rotation_degrees = diss_positions_control.active_diss_zone_angle
		
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
	
