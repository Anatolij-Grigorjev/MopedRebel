extends Node

var LOG = preload("res://globals/logger.gd").new(self)

const KEY_COMMON_PHRASES = "common"
const KEY_SPECIFIC_PHRASES = "specific"

enum PHRASE_TYPES {
	#things said by manager in charge of moped rebel
	MANAGER = 0,
	#bribes said by rebel during conflict
	BRIBES = 1,
	#disses said by rebel during conflict
	DISSES = 2
}

var _all_phrases_list = []

func _ready():
	
	var bribes_phrases = _parse_common_specific_phrases_model_json(
		C.BRIBE_JSON_LOCATION
	)
	var disses_phrases = _parse_common_specific_phrases_model_json(
		C.DISS_JSON_LOCATION
	)
	var manager_phrases = _parse_dict_phrases_model_json(
		C.MANAGER_JSON_LOCATION
	)
	
	_all_phrases_list.append(manager_phrases)
	_all_phrases_list.append(bribes_phrases)
	_all_phrases_list.append(disses_phrases)
	
	print("Loaded random phrase engine node PE!")
	
func _parse_common_specific_phrases_model_json(json_location):
	var all_phrases_model = F.parse_json_file_as_var(
		json_location
	)
	if (not all_phrases_model.has(KEY_SPECIFIC_PHRASES)):
		all_phrases_model[KEY_SPECIFIC_PHRASES] = []
	#ensure file had at least some common disses
	F.assert_dict_props(all_phrases_model, [KEY_COMMON_PHRASES, KEY_SPECIFIC_PHRASES])
	F.assert_arr_not_empty(all_phrases_model[KEY_COMMON_PHRASES])
	
	return all_phrases_model
	
func _parse_dict_phrases_model_json(json_location):
	var all_phrases_dict = F.parse_json_file_as_var(
		json_location
	)
	F.assert_not_null(all_phrases_dict)
	
	return all_phrases_dict

	
func _get_random_common_phrase(phrase_type_key):
	_assert_valid_phrase_type(phrase_type_key)
		
	var common_phrases = _all_phrases_list[phrase_type_key][KEY_COMMON_PHRASES]
	return F.get_rand_array_elem(common_phrases)
	
func _assert_valid_phrase_type(phrase_type_key):
	if (phrase_type_key >= _all_phrases_list.size()):
		F.log_error("Unrecognized phrase type %s", [phrase_type_key])
	
func get_random_enemy_diss(enemy_node_name = null):
	if (enemy_node_name):
		return _get_random_specific_phrase(PHRASE_TYPES.DISSES, enemy_node_name)
	else:
		return _get_random_common_phrase(PHRASE_TYPES.DISSES)
	
func get_random_enemy_bribe(enemy_node_name = null):
	if (enemy_node_name):
		return _get_random_specific_phrase(PHRASE_TYPES.BRIBES, enemy_node_name)
	else:
		return _get_random_common_phrase(PHRASE_TYPES.BRIBES)
		
func get_specific_manager_phrase(phrase_key):
	var manager_phrases = _all_phrases_list[PHRASE_TYPES.MANAGER]
	if (manager_phrases.has(phrase_key)):
		return manager_phrases[phrase_key]
	else:
		LOG.error("No manager phrase found for phrase key %s", [phrase_key])

func _get_random_specific_phrase(phrase_type_key, specifier_string):
	_assert_valid_phrase_type(phrase_type_key)
	
	var all_phrases_of_type = _all_phrases_list[phrase_type_key]
	var specific_phrases = all_phrases_of_type[KEY_SPECIFIC_PHRASES]
	var common_phrases = all_phrases_of_type[KEY_COMMON_PHRASES]
	#common phrases are good for all enemies
	var all_suitable_phrases_num = common_phrases.size()
	#iterating keys
	var specific_phrases_num = 0
	var specific_phrases_lists = []
	for name_part in specific_phrases:
		if (specifier_string.findn(name_part) > -1):
			var suitable_specific_phrases = specific_phrases[name_part]
			specific_phrases_lists.append(suitable_specific_phrases)
			specific_phrases_num += suitable_specific_phrases.size()
			all_suitable_phrases_num += suitable_specific_phrases.size()
	
	var selected_phrase_idx = randi() % all_suitable_phrases_num
	var local_selected_idx = selected_phrase_idx
	var current_specifics_list_idx = 0
	while (
		local_selected_idx >= 0
		and current_specifics_list_idx < specific_phrases_lists.size()
	):
		local_selected_idx -= specific_phrases_lists[current_specifics_list_idx].size()
		current_specifics_list_idx += 1
	
	if (local_selected_idx < 0):
		var phrases_list = specific_phrases_lists[current_specifics_list_idx]
		return phrases_list[local_selected_idx]
	else:
		return common_phrases[local_selected_idx]
