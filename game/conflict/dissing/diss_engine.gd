extends Node

var all_disses_model = {}
var has_specific_disses = false

var KEY_COMMON_DISSES = "common"
var KEY_SPECIFIC_DISSES = "specific"

func _ready():
	
	all_disses_model = F.parse_json_file_as_var(
		C.DISS_JSON_LOCATION
	)
	if (not all_disses_model.has(KEY_SPECIFIC_DISSES)):
		all_disses_model[KEY_SPECIFIC_DISSES] = []
	#ensure file had at least some common disses
	F.assert_dict_props(all_disses_model, [KEY_COMMON_DISSES, KEY_SPECIFIC_DISSES])
	F.assert_arr_not_empty(all_disses_model[KEY_COMMON_DISSES])
	has_specific_disses = not all_disses_model[KEY_SPECIFIC_DISSES].empty()
	print("Loaded diss engine node DE!")
	pass
	

func get_random_common_diss():
	var common_disses = all_disses_model[KEY_COMMON_DISSES]
	return F.get_rand_array_elem(common_disses)
	
func get_random_enemy_diss(enemy_node_name):
	if (not has_specific_disses):
		F.logf("WARN!!! Dissing %s with common, no specifics...", [enemy_node_name])
		return get_random_common_diss()
	var specific_disses = all_disses_model[KEY_SPECIFIC_DISSES]
	var all_suitable_disses = Array(all_disses_model[KEY_COMMON_DISSES])
	#iterating keys
	for name_part in specific_disses:
		if (enemy_node_name.findn(name_part) > -1):
			F.add_base_array_all_elems(
				all_suitable_disses, 
				specific_disses[name_part]
			)
			
	return F.get_rand_array_elem(all_suitable_disses)


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
