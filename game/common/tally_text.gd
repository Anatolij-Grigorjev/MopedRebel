extends Label

enum INFO_TYPE {
	NEGATIVE = -1,
	INFO = 0,
	POSITIVE = 1
}

export(INFO_TYPE) var text_type = INFO

var color_by_type = {
	INFO_TYPE.NEGATIVE: Color(1.0, 0.0, 0.0),
	INFO_TYPE.INFO: Color(0.0, 1.0, 0.0),
	INFO_TYPE.POSITIVE: Color(0.0, 0.0, 1.0)
}

func _ready():
	
	add_color_override("font_color", color_by_type[text_type])
	
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
	
	F.invoke_later(self, 'queue_free', 0.1 + $text_anim.get_runtime())
	$text_anim.start()
