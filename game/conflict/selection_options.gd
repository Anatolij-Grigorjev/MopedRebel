extends VBoxContainer

var LOG = preload("res://globals/logger.gd").new(self)

var option_containers = []
var option_normal_text = []
var option_selected_detail_text = []

var option_selected_detail_templates = [
	"will cost $%s",
	"have at least %s SC points",
	"enemy toughness rating: %s"
]

var curr_selection_idx = 0
var option_picked = false
var enemy_sprite_node
var rebel_sprite_node

var param_req_money
var param_req_sc
var param_enemy_toughness

func _ready():
	enemy_sprite_node = owner.get_node('outer_container/chars_outer_container/pictures_container/enemy_tex')
	rebel_sprite_node = owner.get_node('outer_container/chars_outer_container/pictures_container/rebel_tex')
	init_options_containers_data()
	init_conflict_with_details(null, 0, 0, 'DUMMY')
	
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


func init_conflict_with_details(enemy_texture, req_money, req_sc, enemy_rating):
	var detail_param = [req_money, req_sc, enemy_rating]
	param_req_money = detail_param[0]
	param_req_sc = detail_param[1]
	param_enemy_toughness = detail_param[2]
	option_selected_detail_text.clear()
	for idx in range(0, option_selected_detail_templates.size()):
		var detail_template = option_selected_detail_templates[idx]
		var detail_text = detail_template % detail_param[idx]
		option_selected_detail_text.append(detail_text)
	_apply_conflict_textures(enemy_texture)
	mark_selected_option()
	
func _apply_conflict_textures(enemy_texture):
	if (enemy_texture != null):
		enemy_sprite_node.texture = enemy_texture
	rebel_sprite_node.texture = G.node_active_rebel.active_sprite.texture

	
func mark_selected_option():
	F.assert_arr_not_empty(option_selected_detail_text)
	_clear_selection()
	_correct_selection_idx()
	var label_node = option_containers[curr_selection_idx].get_node('selection_arrow')
	label_node.text = C.GUI_SELECTED_OPT_MARKER
	var text_node = option_containers[curr_selection_idx].get_node('text_label')
	var normal_text = option_normal_text[curr_selection_idx]
	var detail_text = option_selected_detail_text[curr_selection_idx]
	text_node.text = "%s (%s)" % [normal_text, detail_text]
	if (_option_requirements_met(curr_selection_idx)):
		text_node.add_color_override('font_color', C.GUI_AVAILABLE_OPTION_COLOR)
	else:
		text_node.add_color_override('font_color', C.GUI_REQ_NOT_MET_OPTION_COLOR)
	
func _correct_selection_idx():
	if (curr_selection_idx < 0):
		curr_selection_idx = option_containers.size() + curr_selection_idx
	else:
		curr_selection_idx = curr_selection_idx % option_containers.size()
	
func _clear_selection():
	for idx in range(0, option_containers.size()):
		var container_node = option_containers[idx]
		container_node.get_node('selection_arrow').text = ''
		container_node.get_node('text_label').text = option_normal_text[idx]
		if (_option_requirements_met(idx)):
			container_node.get_node('text_label').add_color_override('font_color', C.GUI_AVAILABLE_OPTION_COLOR)
		else:
			container_node.get_node('text_label').add_color_override('font_color', C.GUI_NOT_AVAILABLE_OPTION_COLOR)

func _option_requirements_met(option_idx):
	match option_idx:
		0:
			return G.rebel_total_money >= param_req_money
		1: 
			return G.rebel_total_street_cred >= param_req_sc
		2:
			return true
		_:
			LOG.error(
				'Checking unexpected option idx %s!', 
				[option_idx]
			)

func _physics_process(delta):
	if (not option_picked):
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
	if (Input.is_action_just_released('unmount_moped')
		and _option_requirements_met(curr_selection_idx)):
		option_picked = true
		match curr_selection_idx:
			0:
				_process_picked_bribe()
			1: 
				_process_picked_diss()
			2:
				_process_picked_fight()
			_:
				LOG.error(
					'Picked weird option idx %s!', 
					[curr_selection_idx]
				)
				
func _process_picked_bribe():
	var chosen_bribe_text = null
	if (VS.conflict_with_node == null):
		chosen_bribe_text = PE.get_random_common_bribe() % param_req_money
	else:
		chosen_bribe_text = PE.get_random_enemy_bribe(VS.conflict_with_node.name) % param_req_money
		
	S.emit_signal1(
		S.SIGNAL_CONFLICT_CHOSE_BRIBE,
		chosen_bribe_text
	)
	
func _process_picked_diss():
	var chosen_diss = null
	if (VS.conflict_with_node == null):
		chosen_diss = PE.get_random_common_diss()
	else:
		chosen_diss = PE.get_random_enemy_diss(VS.conflict_with_node.name)
		
	LOG.debug("MR: %s", [chosen_diss])
	S.emit_signal1(
		S.SIGNAL_CONFLICT_CHOSE_DISS,
		chosen_diss
	)

	
func _process_picked_fight():
	pass
