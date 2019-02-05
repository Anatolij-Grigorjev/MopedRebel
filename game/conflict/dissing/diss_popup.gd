extends PopupDialog

var screen_size_ratio

var latest_diss_text = ""
var diss_text_label

func _ready():
	diss_text_label = $margins/text_container/diss_text
	screen_size_ratio = 0.4
	pass
	
func show_popup(diss_text):
	latest_diss_text = diss_text
	diss_text_label.text = diss_text
	
	popup_centered_ratio(screen_size_ratio)
	pass

func _ok_button_pressed():
	hide()
