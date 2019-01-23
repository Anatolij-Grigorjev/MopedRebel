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
	init_conflict_detail_params(560, 277, 'WHIMP')
	mark_selected_option()
	
func init_options_containers_data():
	option_containers = [
		$option_bribe,
		$option_diss,
		$option_fight
	]
	for container in option_containers:
		var normal_text = container.get_node('text_label').text
		option_normal_text.append(normal_text)


func init_conflict_detail_params(req_money, req_sc, enemy_rating):
	var detail_param = [req_money, req_sc, enemy_rating]
	for idx in range(0, option_selected_detail_templates.size()):
		var detail_template = option_selected_detail_templates[idx]
		var detail_text = detail_template % detail_param[idx]
		option_selected_detail_text.append(detail_text)

	
func mark_selected_option():
	clear_selection()
	correct_selection_idx()
	var label_node = option_containers[curr_selection_idx].get_node('selection_arrow')
	label_node.text = C.GUI_SELECTED_OPT_MARKER
	var text_node = option_containers[curr_selection_idx].get_node('text_label')
	var normal_text = option_normal_text[curr_selection_idx]
	var detail_text = option_selected_detail_text[curr_selection_idx]
	text_node.text = "%s (%s)" % [normal_text, detail_text]
	
func correct_selection_idx():
	curr_selection_idx = curr_selection_idx % option_containers.size()
	
func clear_selection():
	for idx in range(0, option_containers.size()):
		var container_node = option_containers[idx]
		container_node.get_node('selection_arrow').text = ''
		container_node.get_node('text_label').text = option_normal_text[idx]
		
		
func _physics_process(delta):
	
	var input_happened = false
	
	if (Input.is_action_just_released('walk_down')):
		curr_selection_idx += 1
		input_happened = true
	if (Input.is_action_just_released('walk_up')):
		curr_selection_idx -= 1
		input_happened = true
	
	if (input_happened):
		mark_selected_option()



