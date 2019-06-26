extends PopupDialog

export(float) var visible_time = 1.5
export(String) var shout_line = ''

func _ready():
	$dissapear_timer.one_shot = true
	$dissapear_timer.autostart = false
	$dissapear_timer.connect('timeout', self, '_free_popup')
	$shout_line.text = shout_line
	$dissapear_timer.wait_time = visible_time
	
func _prepare_popup():
	rect_position -= (rect_size / 2 )


func show_popup():
	#TODO: check existing popups, precendence for fight dss over mock
	popup()
	$dissapear_timer.start()
	
func _free_popup():
	call_deferred('queue_free')
