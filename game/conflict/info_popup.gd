extends PopupDialog

var screen_size_ratio

var latest_info_text = ""
var info_text_label

func _ready():
	info_text_label = $margins/text_container/info_text
	screen_size_ratio = 0.4
	pass
	
func show_popup(info_text):
	latest_info_text = info_text
	info_text_label.text = info_text
	
	popup_centered_ratio(screen_size_ratio)
	pass

func _ok_button_pressed():
	S.emit_signal0(
		S.SIGNAL_INFO_POPUP_CLOSED
	)
	queue_free()
	hide()
