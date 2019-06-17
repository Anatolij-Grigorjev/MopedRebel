extends Resource

export (String) var type_id
export (float) var fear_sc
export (float) var escape_delay_sec
export (PoolStringArray) var disses 


func _init(type_key):
	F.assert_string_not_blank(type_key)
	var type_props = L.loaded_enemies_props[type_key]
	
	F.assert_dict_props(type_props, ['fear_sc', 'escape_delay_sec', 'disses'])
	F.assert_arr_not_empty(type_props['disses'])
	
	fear_sc = type_props['fear_sc']
	escape_delay_sec = type_props['escape_delay_sec']
	disses = type_props['disses']
	
func as_string():
	return """BASE PROPS:
	Enemy type id: %s
	base fear SC: %s,
	base escape delay (sec): %s
	num disses: %s
	""" % [type_id, fear_sc, escape_delay_sec, disses.size()]
