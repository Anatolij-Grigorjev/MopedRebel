extends StaticBody2D

export(float) var fadein_start_distance = 250
export(float) var fadein_done_distance = 50

func _ready():
	pass
	
func _process(delta):
	var distance_to_rebel = global_position.distance_to(G.node_active_rebel.global_position)
	if (distance_to_rebel < fadein_done_distance):
		modulate.a = 1
	elif (fadein_done_distance < distance_to_rebel and distance_to_rebel < fadein_start_distance):
		modulate.a = 1 - (distance_to_rebel - fadein_done_distance) / (fadein_start_distance - fadein_done_distance)
	else:
		modulate.a = 0

func _rebel_start_escape(escape_time):
	_reset_tween()
	$escape_color_modulate.interpolate_property(
		self, 'modulate:a', 
		modulate.a, 0.0, 
		escape_time, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	
func _reset_tween():
	$escape_color_modulate.stop_all()
	modulate.a = 1.0
	
func _rebel_stop_escape(elapsed_escape_time):
	_reset_tween()
