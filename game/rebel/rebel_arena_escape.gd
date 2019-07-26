extends Area2D

signal rebel_escaped(delivery_time_penalty)
signal rebel_start_escape(escape_time)
signal rebel_stop_escape(spent_time)

export(float) var escape_time_seconds = 2.5
var delivery_time_penalty = 0

func _ready():
	$escape_timer.wait_time = escape_time_seconds
	$escape_timer.connect("timeout", self, "perform_rebel_escape")


func _start_touch_arena_wall(wall_node):
	$escape_timer.start()
	emit_signal("rebel_start_escape", escape_time_seconds)
	
	
func _stop_touch_arena_wall(wall_node):
	var elapsed = F.get_elapsed_timer_time($escape_timer)
	$escape_timer.stop()
	emit_signal("rebel_stop_escape", elapsed)

func perform_rebel_escape():
	VS.end_active_conflict()
	emit_signal("rebel_escaped", delivery_time_penalty)
	queue_free()