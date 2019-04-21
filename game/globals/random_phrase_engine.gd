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
	
	var bribes = _parse_common_specific_phrases_model_json(
		C.BRIBE_JSON_LOCATION
	)
	var disses = _parse_common_specific_phrases_model_json(
		C.DISS_JSON_LOCATION
	)
	var manager_phrases = _parse_monolithic_phrases_model_json(
		C.MANAGER_JSON_LOCATION
	)
	
	_all_phrases_list.append({
		KEY_COMMON_PHRASES: manager_phrases,
		KEY_SPECIFIC_PHRASES: {}
	})
	_all_phrases_list.append(bribes)
	_all_phrases_list.append(disses)
	
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
	
func _parse_monolithic_phrases_model_json(json_location):
	var all_phrases_list = F.parse_json_file_as_var(
		json_location
	)
	F.assert_arr_not_empty(all_phrases_list)
	
	return all_phrases_list

	
func _get_random_common_phrase(phrase_type_key):
	_assert_valid_phrase_type(phrase_type_key)
		
	var common_phrases = _all_phrases_list[phrase_type_key][KEY_COMMON_PHRASES]
	return F.get_rand_array_elem(common_phrases)
	
func _assert_valid_phrase_type(phrase_type_key):
	if (phrase_type_key >= _all_phrases_list.size()):
		F.log_error("Unrecognized phrase type %s", [phrase_type_key])
	
func get_random_enemy_diss(enemy_node_name = null):
	if (enemy_node_name == null):
		return _get_random_common_phrase(PHRASE_TYPES.DISSES)
	else:
		return _get_random_specific_phrase(PHRASE_TYPES.DISSES, enemy_node_name)
	
func get_random_enemy_bribe(enemy_node_name = null):
	if (enemy_node_name == null):
		return _get_random_common_phrase(PHRASE_TYPES.BRIBES)
	else:
		return _get_random_specific_phrase(PHRASE_TYPES.BRIBES, enemy_node_name)

func _get_random_specific_phrase(phrase_type_key, specifier_string):
	_assert_valid_phrase_type(phrase_type_key)
	
	var all_phrases_of_type = _all_phrases_list[phrase_type_key]
	var specific_phrases = all_phrases_of_type[KEY_SPECIFIC_PHRASES]
	var all_suitable_phrases = []
	#common phrases are good for all enemies
	F.add_base_array_all_elems(
		all_suitable_phrases, 
		all_phrases_of_type[KEY_COMMON_PHRASES]
	)
	#iterating keys
	for name_part in specific_phrases:
		if (specifier_string.findn(name_part) > -1):
			F.add_base_array_all_elems(
				all_suitable_phrases, 
				specific_phrases[name_part]
			)
	return F.get_rand_array_elem(all_suitable_phrases)
