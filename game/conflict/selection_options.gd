extends VBoxContainer

var option_containers = []
var option_normal_text = []
var option_selected_detail_text = []

var option_selected_detail_templates = [
	"will cost $%s",
	"have at least %s SC points",
	"enemy toughness rating: %s"
]

var curr_selection_idx = 0


func _ready():
	init_options_containers_data()
	init_conflict_with_details(0, 0, 'DUMMY')
	
func init_options_containers_data():
	option_containers = [
		$option_bribe,
		$option_diss,
		$option_fight
	]
	option_normal_text.clear()
	for container in option_containers:
		var normal_text = container.get_node('text_label').text
		option_normal_text.append(normal_text)


func init_conflict_with_details(req_money, req_sc, enemy_rating):
	var detail_param = [req_money, req_sc, enemy_rating]
	option_selected_detail_text.clear()
	for idx in range(0, option_selected_detail_templates.size()):
		var detail_template = option_selected_detail_templates[idx]
		var detail_text = detail_template % detail_param[idx]
		option_selected_detail_text.append(detail_text)
	mark_selected_option()

	
func mark_selected_option():
	F.assert_arr_not_empty(option_selected_detail_text)
	clear_selection()
	correct_selection_idx()
	var label_node = option_containers[curr_selection_idx].get_node('selection_arrow')
	label_node.text = C.GUI_SELECTED_OPT_MARKER
	var text_node = option_containers[curr_selection_idx].get_node('text_label')
	var normal_text = option_normal_text[curr_selection_idx]
	var detail_text = option_selected_detail_text[curr_selection_idx]
	text_node.text = "%s (%s)" % [normal_text, detail_text]
	
func correct_selection_idx():
	if (curr_selection_idx < 0):
		curr_selection_idx = option_containers.size() + curr_selection_idx
	else:
		curr_selection_idx = curr_selection_idx % option_containers.size()
	
func clear_selection():
	for idx in range(0, option_containers.size()):
		var container_node = option_containers[idx]
		container_node.get_node('selection_arrow').text = ''
		container_node.get_node('text_label').text = option_normal_text[idx]


func _physics_process(delta):
	_process_browse_options()
	_process_pick_option()

func _process_browse_options():
	var prev_selection_idx = curr_selection_idx
	if (Input.is_action_just_released('walk_up')):
		curr_selection_idx -= 1
	if (Input.is_action_just_released('walk_down')):
		curr_selection_idx += 1
	if (prev_selection_idx != curr_selection_idx):
		mark_selected_option()
		
func _process_pick_option():
	if (Input.is_action_just_released('unmount_moped')):
		match curr_selection_idx:
			0:
				_process_picked_bribe()
			1: 
				_process_picked_diss()
			2:
				_process_picked_fight()
			_:
				F.log_error(
					'Picked weird option %s!', 
					[curr_selection_idx]
				)
				
func _process_picked_bribe():
	_finish_return_to_stage()
	pass
func _process_picked_diss():
	
	var chosen_diss = (
		DE.get_random_enemy_diss(VS.conflict_with_node.name) 
		if VS.conflict_with_node != null 
		else DE.get_random_common_diss()
	)
	F.logf("MR: %s", [chosen_diss])
	S.emit_signal1(
		S.SIGNAL_CONFLICT_CHOSE_DISS,
		chosen_diss
	)
	_finish_return_to_stage()
	pass
func _process_picked_fight():
	pass
	
func _finish_return_to_stage():
	S.emit_signal0(S.SIGNAL_CONFLICT_RESOLVED)
	pass
