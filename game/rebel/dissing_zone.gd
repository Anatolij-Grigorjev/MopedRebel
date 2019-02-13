extends Area2D

var present_nodes = []
var tally_timer
var exclude_collision_node

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
	if (body.has_method('enter_diss_zone')):
		body.enter_diss_zone()
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
	if (body.has_method('exit_diss_zone')):
		body.exit_diss_zone()


func _count_dissing_tally():
	var total_gained_sc = 0
	for enemy_node in present_nodes:
		for group in enemy_node.get_groups():
			total_gained_sc += C.SC_GAIN_FOR_GROUP[group] if C.SC_GAIN_FOR_GROUP.has(group) else 0
	
	if (total_gained_sc > 0):
		S.emit_signal1(
			S.SIGNAL_REBEL_GAIN_SC,
			total_gained_sc
		)
	
