extends Node2D

var LOG = preload("res://globals/logger.gd").new(self)

enum DISS_STATES {
	NOT_ACTIVE,
	GETTING_DISSED,
	ACTIVE_DISSED,
	DISSED_COOLING_DOWN
}
var diss_states_array = DISS_STATES.keys()

export(bool) var receiver_enabled = true
export(float) var initial_diss_tolerance_time
export(float) var initial_diss_calmdown_time
export(String) var diss_success_action_name
export(String) var diss_calmdown_action_name
export(String) var diss_began_action_name
export(String) var diss_stopped_action_name
export(String) var diss_reduction_predicate_name

#NODE VARS
var diss_tolerance_timer
var diss_calmdown_timer
var diss_indicator_sprite
var node_owner

#INTERNAL VARS
var is_dissed = false
var diss_buildup_coef = 0.0

func _ready():
	node_owner = owner
	diss_tolerance_timer = $diss_tolerance_timer
	diss_calmdown_timer = $diss_calmdown_timer
	diss_indicator_sprite = $diss_indicator
	_set_diss_buildup_coef(0.0)
	if (initial_diss_tolerance_time):
		diss_tolerance_timer.wait_time = initial_diss_tolerance_time
	else:
		initial_diss_tolerance_time = diss_tolerance_timer.wait_time
	if (initial_diss_calmdown_time):
		diss_calmdown_timer.wait_time = initial_diss_calmdown_time
	else:
		initial_diss_calmdown_time = diss_calmdown_timer.wait_time
	
	diss_tolerance_timer.connect('timeout', self, '_execute_dissed_current_action')
	diss_calmdown_timer.connect('timeout', self, '_execute_calm_current_action')
	$debug_coef_timer.connect('timeout', self, 'print_debug_info')
	#configure logger to ouput owner name and this as type
	LOG.entity_name = node_owner.name
	LOG.entity_type_descriptor = "[diss-recv]"
	#enable debug logging if debug level is set
	if (C.CURRENT_LOG_LEVEL <= C.LOG_LEVELS.DEBUG):
		$debug_coef_timer.start()
	pass
	
	
func get_active_diss_state():
	if (is_dissed):
		if (diss_calmdown_timer.is_stopped()):
			return ACTIVE_DISSED
		else:
			return DISSED_COOLING_DOWN
	else:
		if (diss_tolerance_timer.is_stopped()):
			return NOT_ACTIVE
		else:
			return GETTING_DISSED
	
func _set_diss_buildup_coef(coef):
	diss_buildup_coef = coef
	diss_indicator_sprite.modulate.a = diss_buildup_coef
	
func _process(delta):
	
	_check_stop_calmdown_timer()
	_check_start_calmdown_timer()
	
	#alter enemy diss levels
	var active_diss_state = get_active_diss_state()
	
	var new_diss_coef = 0.0
	match(active_diss_state):
		GETTING_DISSED:
			new_diss_coef = F.get_coef_for_absolute(
				F.get_elapsed_timer_time(diss_tolerance_timer),
				diss_tolerance_timer.wait_time
			)
		ACTIVE_DISSED:
			new_diss_coef = clamp(
				diss_buildup_coef + F.get_coef_for_absolute(delta, diss_calmdown_timer.wait_time),
				0.0,
				1.0
			)
		DISSED_COOLING_DOWN:
			new_diss_coef = F.get_coef_for_absolute(
				diss_calmdown_timer.time_left,
				diss_calmdown_timer.wait_time
			)
		_:
			new_diss_coef = clamp(
				diss_buildup_coef - F.get_coef_for_absolute(delta, diss_tolerance_timer.wait_time),
				0.0,
				1.0
			)	
	if (new_diss_coef != diss_buildup_coef):
		_set_diss_buildup_coef(new_diss_coef)

func _check_start_calmdown_timer():
	if (is_dissed and diss_calmdown_timer.is_stopped()):
		if (node_owner.call(diss_reduction_predicate_name)):
			diss_calmdown_timer.wait_time = initial_diss_calmdown_time - F.get_absolute_for_coef(
				1.0 - diss_buildup_coef, 
				initial_diss_tolerance_time
			)
			diss_calmdown_timer.start()
			
func _check_stop_calmdown_timer():
	if (is_dissed and not diss_calmdown_timer.is_stopped()):
		if (not node_owner.call(diss_reduction_predicate_name)):
			diss_buildup_coef = F.get_coef_for_absolute(
				diss_calmdown_timer.time_left
			)
			diss_calmdown_timer.stop()
	
func start_receive_diss():
	if (not is_dissed):
		#use the not cooled disshood to get dissed faster
		if (diss_buildup_coef > 0):
			diss_tolerance_timer.wait_time = initial_diss_tolerance_time - F.get_absolute_for_coef(
				diss_buildup_coef,
				initial_diss_tolerance_time
			)
		diss_tolerance_timer.start()
		_execute_optional_around_action(diss_began_action_name)
	
func stop_receive_diss():
	if (not is_dissed):
		diss_tolerance_timer.stop()
		_execute_optional_around_action(diss_stopped_action_name)
		
func finish_being_dissed():
	is_dissed = false
	_set_diss_buildup_coef(0.0)
	diss_tolerance_timer.wait_time = initial_diss_tolerance_time
	diss_calmdown_timer.wait_time = initial_diss_calmdown_time
	diss_tolerance_timer.stop()
	diss_calmdown_timer.stop()
	
func set_diss_tolerance_seconds(seconds):
	_stop_running_timer(diss_tolerance_timer)
	initial_diss_tolerance_time = seconds
	diss_tolerance_timer.wait_time = seconds
	
func set_diss_calmdown_seconds(seconds):
	_stop_running_timer(diss_calmdown_timer)
	initial_diss_calmdown_time = seconds
	diss_calmdown_timer.wait_time = seconds
	
func shutdown_receiver():
	receiver_enabled = false
	$diss_tolerance_timer.stop()
	$diss_calmdown_timer.stop()
	$debug_coef_timer.stop()
	is_dissed = false
	
func startup_receiver():
	receiver_enabled = true
	if (C.CURRENT_LOG_LEVEL >= C.LOG_LEVELS.DEBUG):
		$debug_coef_timer.start()
	is_dissed = false
	
func _stop_running_timer(timer):
	if (not timer.is_stopped()):
		timer.stop()

func _execute_dissed_current_action():
	#if timeout reached we reset how long it takes to get dissed
	is_dissed = true
	_set_diss_buildup_coef(1.0)
	diss_tolerance_timer.wait_time = initial_diss_tolerance_time
	diss_calmdown_timer.wait_time = initial_diss_calmdown_time
	if (node_owner != null and node_owner.has_method(diss_success_action_name)):
		node_owner.call(diss_success_action_name)
	else:
		LOG.error("Missing owner node %s or it doesnt have method %s!", 
			[node_owner, diss_success_action_name]
		)
		
func _execute_calm_current_action():
	is_dissed = false
	_set_diss_buildup_coef(0.0)
	diss_tolerance_timer.wait_time = initial_diss_tolerance_time
	diss_calmdown_timer.wait_time = initial_diss_calmdown_time
	if (node_owner != null and node_owner.has_method(diss_calmdown_action_name)):
		node_owner.call(diss_calmdown_action_name)
	else:
		LOG.warn("Missing owner node %s or it doesnt have method %s!", 
			[node_owner, diss_calmdown_action_name]
		)
		
func _execute_optional_around_action(action_name):
	if (node_owner != null 
		and action_name != null
		and node_owner.has_method(action_name)
	):
		node_owner.call(action_name)
		
func print_debug_info():
	var active_diss_state = get_active_diss_state()
	if (diss_buildup_coef == 0.0 and active_diss_state == NOT_ACTIVE):
		return
	LOG.info("diss coef: %s | state: %s", [
		diss_buildup_coef, 
		diss_states_array[active_diss_state]
	])
