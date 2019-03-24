extends StaticBody2D

func _ready():
	$post_leave_wait.stop()
	pass

func _screen_exited():
	$post_leave_wait.stop()
	$post_leave_wait.start()

func _screen_entered():
	#reset timer when car onscreen
	#not to dissapear it
	if (not $post_leave_wait.is_stopped()):
		$post_leave_wait.stop()
	
func _offscreen_grace_timeout():
	queue_free()
