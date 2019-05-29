extends Label

func _ready():
	
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
	
	F.invoke_later(self, 'queue_free', 0.4)
	$text_anim.start()
