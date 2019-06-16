extends Resource

export (String) var type_id
export (float) var fear_sc
export (float) var escape_delay_sec
export (PoolStringArray) var disses 


func _init(props_json_path, type_key):
	F.assert_string_not_blank(type_key)
	var full_json = F.parse_json_file_as_var(props_json_path)
	type_id = type_key
	var type_props = full_json[type_key]
	
	F.assert_dict_props(type_props, ['fear_sc', 'escape_delay_sec', 'disses'])
	F.assert_arr_not_empty(type_props['disses'])
	
	fear_sc = type_props['fear_sc']
	escape_delay_sec = type_props['escape_delay_sec']
	disses = type_props['disses']
	
func as_string():
	return """
	Enemy type id: %s
	base fear SC: %s,
	base escape delay (sec): %s
	num disses: %s
	""" % [type_id, fear_sc, escape_delay_sec, disses.size()]
