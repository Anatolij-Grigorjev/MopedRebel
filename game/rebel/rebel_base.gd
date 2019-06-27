extends KinematicBody2D

var Logger = preload("res://globals/logger.gd")
var LOG

var DissZone = preload("res://rebel/dissing_zone.tscn")
var active_dissing_zone

var ShoutPopup = preload("res://common/shout_popup.tscn")

var diss_positions_control
var low_position
var camera
var active_sprite

var facing_direction = C.FACING.RIGHT
var velocity = Vector2()

var enabled = true
var control_locked = false

func _ready():
	active_sprite = $sprite
	diss_positions_control = $diss_positions
	low_position = $low_collider
	camera = $camera
	S.connect_signal_to(S.SIGNAL_ENEMY_SCARED, self, '_shout_at_enemy')
	S.connect_signal_to(S.SIGNAL_ENEMY_DISSED, self, '_shout_at_enemy')
	
	
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
			active_dissing_zone = DissZone.instance()
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
		
func _shout_at_enemy(enemy_node):
	if (self != G.node_active_rebel):
		return 
	if (enemy_node.is_scared):
		pass
	else:
		var props = enemy_node.get_node('type_props')
		var random_diss = F.get_rand_array_elem(props.disses)
		shout_for_seconds(global_position, random_diss, 1.5)
	pass
	
func shout_for_seconds(shout_global_position, shout_line, for_seconds):
	LOG.info("rebel shouting %s at %s for %s seconds", [
	shout_line, shout_global_position, for_seconds])
	var shout_dialog = ShoutPopup.instance()
	shout_dialog.shout_line = shout_line
	shout_dialog.visible_time = for_seconds
	add_child(shout_dialog)
	var half_rebel_height = active_sprite.texture.get_size().y * scale.y
	var shout_offset = Vector2(0, half_rebel_height)
	shout_dialog.rect_position = global_position - shout_offset
	shout_dialog.show_popup()
	
