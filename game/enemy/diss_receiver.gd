extends Node2D

var diss_tolerance_timer
var node_owner
var diss_success_action_name

func _ready():
	node_owner = get_parent()
	diss_tolerance_timer = $diss_tolerance_timer
	pass
	
func start_receive_diss():
	diss_tolerance_timer.start()
	
func set_action_owner(node_owner):
	if (node_owner == null or diss_success_action_name == null):
		return
	
	_stop_running_timer()
	_disconnect_current_action()
	
	self.node_owner = node_owner
	diss_tolerance_timer.connect('timeout', node_owner, diss_success_action_name)
	

func set_got_dissed_action(action_name):
	if (node_owner == null or diss_success_action_name == null):
		return
	
	_stop_running_timer()
	_disconnect_current_action()
		
	diss_success_action_name = action_name
	diss_tolerance_timer.connect('timeout', node_owner, diss_success_action_name)
	
func set_diss_tolerance_seconds(seconds):
	_stop_running_timer()
	diss_tolerance_timer.wait_time = seconds
	
func get_diss_progress_ratio():
	var elapsed = diss_tolerance_timer.wait_time - diss_tolerance_timer.time_left
	return elapsed / diss_tolerance_timer.wait_time
	
func _stop_running_timer():
	if (not diss_tolerance_timer.is_stopped()):
		diss_tolerance_timer.stop()
		
func _disconnect_current_action():
	if (diss_tolerance_timer.is_connected('timeout', node_owner, diss_success_action_name)):
		diss_tolerance_timer.disconnect('timeout', node_owner, diss_success_action_name)
