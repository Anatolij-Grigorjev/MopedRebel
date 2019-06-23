extends Sprite

var Logger = preload("res://globals/logger.gd")
var LOG

export(bool) var receiver_enabled = true
export(float) var full_diss_tolerance_time = 1.0
export(float) var full_diss_calmdown_time = 1.0
export(String) var diss_reduction_predicate_name

signal got_dissed
signal calmed_down
signal getting_dissed(current_level)
signal calming_down(current_level)

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
	
func _get_diss_buildup_coef():
	return modulate.a
	
func _diss_alter_done(object, key):
	#we can assume object is self and key is modulate:a
	is_dissed = modulate.a == 1.0
	#remove finished tween to pass is_active checks
	diss_alter_tween.stop_all()
	if (is_dissed):
		emit_signal('got_dissed')
	else:
		emit_signal('calmed_down')
	
func _process(delta):
	_check_stop_calmdown_timer()
	if (_get_diss_buildup_coef() > 0.0):
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
		start_diss_alter_tween(1.0)
		emit_signal('getting_dissed', _get_diss_buildup_coef())
	
func stop_receive_diss():
	if (not is_dissed):
		diss_alter_tween.stop_all()
		emit_signal('calming_down', _get_diss_buildup_coef())
		
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
