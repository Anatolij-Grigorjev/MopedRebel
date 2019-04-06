extends VisibilityNotifier2D

export(float) var grace_period = 1.0

func _ready():
	$wait_period.stop()
	$wait_period.wait_time = grace_period
	$wait_period.connect('timeout', self, '_offscreen_grace_timeout')
	
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
	
func _offscreen_grace_timeout():
	var free_target = self
	if (owner != null):
		free_target = owner
	free_target.queue_free()
