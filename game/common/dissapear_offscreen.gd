extends VisibilityNotifier2D

var LOG = preload("res://globals/logger.gd").new(self)

enum OFFSCREEN_ACTION_TYPES {
	FREE_NODE,
	CUSTOM
}

export(float) var action_delay = 1.0
export(OFFSCREEN_ACTION_TYPES) var action_type = OFFSCREEN_ACTION_TYPES.FREE_NODE
export(NodePath) var custom_action_owner
export(String) var custom_action_name

func _ready():
	$wait_period.stop()
	$wait_period.one_shot = true
	$wait_period.wait_time = action_delay
	match(action_type):
		OFFSCREEN_ACTION_TYPES.FREE_NODE:
			$wait_period.connect('timeout', self, '_offscreen_free_node')
		OFFSCREEN_ACTION_TYPES.CUSTOM:
			var node_at_path = self.get_node(custom_action_owner)
			if (node_at_path == null or custom_action_name == null):
				LOG.error('Argumetns not specified for CUSTOM action type post dissapear!')
			$wait_period.connect('timeout', node_at_path, custom_action_name)
		_:
			LOG.error('Unknown post delay action type %s', [action_type])
	
	connect('screen_entered', self, '_screen_entered')
	connect('screen_exited', self, '_screen_exited')
	pass

func _screen_exited():
	$wait_period.stop()
	$wait_period.start()

func _screen_entered():
	#reset timer when node onscreen
	#not to dissapear it
	if (not $wait_period.is_stopped()):
		$wait_period.stop()
	
func _offscreen_free_node():
	var free_target = self
	if (owner != null):
		free_target = owner
	free_target.queue_free()
