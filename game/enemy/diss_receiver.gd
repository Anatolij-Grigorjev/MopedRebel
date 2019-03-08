extends Node2D

var LOG = preload("res://globals/logger.gd").new(self)

enum DISS_STATES {
	NOT_ACTIVE,
	GETTING_DISSED,
	ACTIVE_DISSED,
	DISSED_COOLING_DOWN
}

var diss_tolerance_timer
var initial_diss_tolerance_time
var diss_calmdown_timer
var initial_diss_calmdown_time
var node_owner
var diss_success_action_name
var diss_began_action_name
var diss_stopped_action_name
var diss_reduction_predicate_name
var is_dissed = false
var diss_buildup_coef = 0.0
var diss_indicator_sprite

func _ready():
	node_owner = owner
	diss_tolerance_timer = $diss_tolerance_timer
	diss_calmdown_timer = $diss_calmdown_timer
	diss_indicator_sprite = $diss_indicator
	_set_diss_buildup_coef(0.0)
	initial_diss_tolerance_time = diss_tolerance_timer.wait_time
	initial_diss_calmdown_time = diss_calmdown_timer.wait_time
	diss_tolerance_timer.connect('timeout', self, '_execute_dissed_current_action')
	diss_calmdown_timer.connect('timeout', self, 'finish_being_dissed')
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
	
func _set_diss_buildup_time(time, for_timer):
	_set_diss_buildup_coef(
		F.get_coef_for_absolute(time, for_timer.wait_time)
	)
	
func _set_diss_buildup_coef(coef):
	diss_buildup_coef = coef
	diss_indicator_sprite.modulate.a = diss_buildup_coef
	
func _process(delta):
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
			new_diss_coef = 1.0
		DISSED_COOLING_DOWN:
			new_diss_coef = F.get_coef_for_absolute(
				F.get_elapsed_timer_time(diss_calmdown_timer),
				diss_calmdown_timer.wait_time
			)
		_:
			new_diss_coef = 0.0

	if (new_diss_coef != diss_buildup_coef):
		_set_diss_buildup_coef(new_diss_coef)
		
	
func start_receive_diss():
	if (not is_dissed):
		#use the not cooled disshood to get dissed faster
		if (diss_buildup_coef > 0):
			diss_tolerance_timer.wait_time -= F.get_absolute_for_coef(
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
	
func _stop_running_timer(timer):
	if (not timer.is_stopped()):
		timer.stop()

func _execute_dissed_current_action():
	#if timeout reached we reset how long it takes to get dissed
	is_dissed = true
	_set_diss_buildup_coef(1.0)
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
