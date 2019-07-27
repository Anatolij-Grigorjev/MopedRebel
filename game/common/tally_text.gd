extends Label

var text_type = C.INFO_TYPE.INFO
var air_time

func _ready():
	
	var info_color = Color(text_type)
	add_color_override("font_color", info_color)
	
	$text_anim.interpolate_property(self, 
		'rect_scale', 
		rect_scale, 
		Vector2(1.0, 1.0), 
		0.25, 
		Tween.TRANS_EXPO, 
		Tween.EASE_OUT
	)
	$text_anim.interpolate_property(self,
		'rect_global_position',
		rect_global_position,
		rect_global_position + Vector2(0, -25),
		0.35,
		Tween.TRANS_EXPO, 
		Tween.EASE_OUT,
		0.05
	)
	if (not air_time):
		air_time = 0.1 + $text_anim.get_runtime()
	F.invoke_later(self, 'queue_free', air_time)
	$text_anim.start()
