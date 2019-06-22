extends Sprite

var Logger = preload("res://globals/logger.gd")
var LOG

enum DISS_STATES {
	NOT_ACTIVE,
	GETTING_DISSED,
	ACTIVE_DISSED,
	DISSED_COOLING_DOWN
}
var diss_states_array = DISS_STATES.keys()

export(bool) var receiver_enabled = true
export(float) var full_diss_tolerance_time = 1.0
export(float) var full_diss_calmdown_time = 1.0
export(String) var diss_success_action_name
export(String) var diss_calmdown_action_name
export(String) var diss_began_action_name
export(String) var diss_stopped_action_name
export(String) var diss_reduction_predicate_name

#NODE VARS
var node_owner
var diss_alter_tween

#INTERNAL VARS
var is_dissed = false

func _ready():
	node_owner = owner
	diss_alter_tween = $diss_alter_tween
	_set_diss_buildup_coef(0.0)
	
	#configure logger to ouput owner name and this as type
	LOG = Logger.new(self)
	LOG.entity_name = "[" + node_owner.name
	LOG.entity_type_descriptor = "|diss-recv]"
	
	diss_alter_tween.connect('tween_completed', self, "_diss_alter_done")

	pass
	
func _set_diss_buildup_coef(coef):
	modulate.a = coef
	
func _diss_alter_done(object, key):
	#we can assume object is self and key is modulate::a
	is_dissed = modulate.a == 1.0
	if (is_dissed):
		_execute_dissed_current_action()
	else:
		_execute_calm_current_action()
	
func get_active_diss_state():
	if (is_dissed):
		if (diss_alter_tween.is_active()):
			return DISSED_COOLING_DOWN
		else:
			return ACTIVE_DISSED
	else:
		if (diss_alter_tween.is_active()):
			return GETTING_DISSED
		else:
			return NOT_ACTIVE
	
func _process(delta):
	_check_stop_calmdown_timer()
	_check_start_calmdown_timer()

func _check_start_calmdown_timer():
	if (not diss_alter_tween.is_active()):
		var should_calm_down = (
			(is_dissed and node_owner.call(diss_reduction_predicate_name))
			or (not is_dissed)
		)
		if (should_calm_down):
			start_diss_alter_tween(0.0)
			
func _check_stop_calmdown_timer():
	if (is_dissed and diss_alter_tween.is_active()):
		if (not node_owner.call(diss_reduction_predicate_name)):
			diss_alter_tween.stop_all()
			
func start_diss_alter_tween(target_value):
	if (target_value == modulate.a):
		return
	var base_time = (full_diss_calmdown_time if target_value < modulate.a 
				else full_diss_tolerance_time)
				
	var actual_time = base_time * F.get_coef_for_absolute(abs(target_value - modulate.a), 1, 0)
	LOG.info("change diss state from %s to %s in %s seconds...", [
		modulate.a,
		target_value,
		actual_time
	])
	diss_alter_tween.remove(self, 'modualte:a')
	diss_alter_tween.interpolate_property(
		self, 'modulate:a', 
		modulate.a, target_value, 
		actual_time, 
		Tween.TRANS_EXPO, Tween.EASE_OUT
	)
	diss_alter_tween.start()
	
func start_receive_diss():
	if (not is_dissed):
		#use the not cooled disshood to get dissed faster
		start_diss_alter_tween(1.0)
		_execute_optional_around_action(diss_began_action_name)
	
func stop_receive_diss():
	if (not is_dissed):
		diss_alter_tween.stop_all()
		_execute_optional_around_action(diss_stopped_action_name)
		
func finish_being_dissed():
	is_dissed = false
	_set_diss_buildup_coef(0.0)
	diss_alter_tween.stop_all()
	
func shutdown_receiver():
	receiver_enabled = false
	diss_alter_tween.reset_all()
	diss_alter_tween.stop_all()
	is_dissed = false
	
func startup_receiver():
	receiver_enabled = true
	is_dissed = false

func _execute_dissed_current_action():
	if (node_owner != null and node_owner.has_method(diss_success_action_name)):
		node_owner.call(diss_success_action_name)
	else:
		LOG.error("Missing owner node %s or it doesnt have method %s!", 
			[node_owner, diss_success_action_name]
		)
		
func _execute_calm_current_action():
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
