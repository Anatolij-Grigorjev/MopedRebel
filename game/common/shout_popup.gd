extends PopupDialog

export(float) var default_visible_time = 1.5
export(String) var default_shout_line = ''

func _ready():
	$dissapear_timer.one_shot = true
	$dissapear_timer.autostart = false
	$dissapear_timer.connect('timeout', self, '_free_popup')


func show_popup(shout_line = default_shout_line, visible_time = default_visible_time):
	$shout_line.text = shout_line
	$dissapear_timer.wait_time = visible_time
	popup_centered()
	$dissapear_timer.start()
	
func _free_popup():
	call_deferred('queue_free')

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
