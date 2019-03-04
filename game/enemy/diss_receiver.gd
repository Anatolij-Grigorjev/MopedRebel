extends Node2D

var LOG = preload("res://globals/logger.gd").new(self)

var diss_tolerance_timer
var initial_diss_tolerance_time
var node_owner
var diss_success_action_name
var diss_began_action_name
var diss_stopped_action_name
var is_dissed = false
var diss_buildup_time = 0
var diss_indicator_sprite

func _ready():
	node_owner = owner
	diss_tolerance_timer = $diss_tolerance_timer
	diss_indicator_sprite = $diss_indicator
	diss_indicator_sprite.modulate.a = 0.0
	initial_diss_tolerance_time = diss_tolerance_timer.wait_time
	diss_tolerance_timer.connect('timeout', self, '_execute_dissed_current_action')
	pass
	
func _process(delta):
	#enemy cooling down
	if (diss_tolerance_timer.is_stopped()):
		if (diss_buildup_time > 0):
			diss_buildup_time = clamp(
				diss_buildup_time - delta, 
				0, 
				diss_buildup_time
			)
			if (diss_buildup_time > 0):
				#show enemy diss sprite based on percentage of dissing
				diss_indicator_sprite.modulate.a = diss_buildup_time / diss_tolerance_timer.wait_time
			else:
				diss_indicator_sprite.modulate.a = 0
	else:
		#enemy getting more dissed, image gets more opaque
		diss_indicator_sprite.modulate.a = get_diss_progress_ratio()
		
	
func start_receive_diss():
	if (not is_dissed):
		#use the not cooled disshood to get dissed faster
		if (diss_buildup_time > 0):
			diss_tolerance_timer.wait_time -= diss_buildup_time
			diss_buildup_time = 0
		diss_tolerance_timer.start()
		_execute_optional_around_action(diss_began_action_name)
	
func stop_receive_diss():
	if (not is_dissed):
		diss_buildup_time = _get_elapsed_timer_time()
		diss_tolerance_timer.stop()
		_execute_optional_around_action(diss_stopped_action_name)
		
func finish_being_dissed():
	is_dissed = false
	diss_buildup_time = 0
	diss_indicator_sprite.modulate.a = 0.0
	diss_tolerance_timer.stop()
	
func set_action_owner(node_owner):
	if (node_owner == null or diss_success_action_name == null):
		return
	_stop_running_timer()
	self.node_owner = node_owner
	

func set_got_dissed_action(action_name):
	if (node_owner == null):
		return
	_stop_running_timer()
	diss_success_action_name = action_name
	
func set_diss_began_action(action_name):
	if (node_owner == null):
		return
	diss_began_action_name = action_name

func set_diss_stopped_action(action_name):
	if (node_owner == null):
		return
	diss_stopped_action_name = action_name
	
func set_diss_tolerance_seconds(seconds):
	_stop_running_timer()
	diss_tolerance_timer.wait_time = seconds
	
func get_diss_progress_ratio():
	var elapsed = _get_elapsed_timer_time()
	return elapsed / diss_tolerance_timer.wait_time
	
func _get_elapsed_timer_time():
	if (diss_tolerance_timer.is_stopped()):
		return diss_buildup_time
	else:
		return diss_tolerance_timer.wait_time - diss_tolerance_timer.time_left
	
func _stop_running_timer():
	if (not diss_tolerance_timer.is_stopped()):
		diss_tolerance_timer.stop()

		
func _execute_dissed_current_action():
	#if timeout reached we reset how long it takes to get dissed
	is_dissed = true
	diss_buildup_time = 0
	diss_indicator_sprite.modulate.a = 1.0
	diss_tolerance_timer.wait_time = initial_diss_tolerance_time
	if (node_owner != null and node_owner.has_method(diss_success_action_name)):
		node_owner.call(diss_success_action_name)
	else:
		LOG.error("Missing owner node %s or it doesnt have method %s!", 
			[node_owner, diss_success_action_name]
		)
		
func _execute_optional_around_action(action_name):
	if (node_owner != null 
		and action_name != null
		and node_owner.has_method(action_name)
	):
		node_owner.call(action_name)
