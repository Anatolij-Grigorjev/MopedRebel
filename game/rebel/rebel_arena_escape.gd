extends Area2D

signal rebel_escaped(escape_time)

export(float) var escape_time_seconds = 2.5
var escape_time = 0


func _ready():
	$escape_timer.wait_time = escape_time_seconds
	$escape_timer.connect("timeout", self, "perform_rebel_escape")
	pass




func perform_rebel_escape():
	F.assert_is_true(escape_time > 0)
	emit_signal("rebel_escaped", escape_time)