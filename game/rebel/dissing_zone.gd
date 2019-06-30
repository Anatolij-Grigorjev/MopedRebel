extends Area2D

var LOG = preload("res://globals/logger.gd").new(self)

var TallyText = preload("res://common/tally_text.tscn")

var present_nodes = []
var tally_timer
var exclude_collision_node

signal rebel_gain_sc(add_sc)

func _ready():
	if (get_parent() != null):
		exclude_collision_node = get_parent()
	tally_timer = $dissing_tally_timer
	tally_timer.one_shot = false
	clear_present_nodes()
	pass

func clear_present_nodes():
	for body in present_nodes:
		_run_body_post_remove(body)
	_check_stop_timer()
	present_nodes.clear()


func _on_dissing_zone_body_entered(body):
	if (body == exclude_collision_node):
		pass
	present_nodes.append(body)
	if (body.has_node('diss_receiver')):
		var diss_receiver = body.get_node('diss_receiver')
		if (diss_receiver.receiver_enabled):
			diss_receiver.start_receive_diss()
	if (tally_timer.is_stopped()):
		tally_timer.start()


func _on_dissing_zone_body_exited(body):
	if (body == exclude_collision_node):
		pass
	var body_idx = present_nodes.find(body)
	if (body_idx >= 0):
		present_nodes.remove(body_idx)
		_run_body_post_remove(body)
		_check_stop_timer()
			
func _check_stop_timer():
	if (present_nodes.empty()):
		tally_timer.stop()
		
func _run_body_post_remove(body):
	if (body == null):
		pass
	if (body.has_node('diss_receiver')):
		var diss_receiver = body.get_node('diss_receiver')
		if (diss_receiver.receiver_enabled):
			diss_receiver.stop_receive_diss()


func _count_dissing_tally():
	var total_gained_sc = 0
	for enemy_node in present_nodes:
		if enemy_node.has_method('get_current_rebel_diss_gain'):
			total_gained_sc += enemy_node.get_current_rebel_diss_gain()
	
	if (total_gained_sc > 0):
		var new_tally = TallyText.instance()
		var diss_zone_extents = $shape.shape.extents
		new_tally.rect_global_position = global_position + Vector2(15, -diss_zone_extents.y)
		new_tally.text = "+%d SC" % total_gained_sc
		G.node_current_stage_root.add_child(new_tally)
		emit_signal("rebel_gain_sc", total_gained_sc)
	
