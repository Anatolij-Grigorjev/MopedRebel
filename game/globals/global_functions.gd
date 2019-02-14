extends Node

#approximate
func y2z(y):
	return round(y * C.Z_COEF)

#approximate
func z2y(z):
	return round(z / C.Z_COEF)

#square
func sqr(a):
	return a * a
	
func add_base_array_all_elems(base_array = [], new_elements = []):
	for new_elem in new_elements:
		base_array.append(new_elem)
		
func get_rand_array_elem(array = []):
	if (array == null or array.empty()):
		return null
	return array[randi() % array.size()]
	
#check if value is in radius of target with a short circuit if equal
func is_val_in_target_radius(val, target, radius):
	return (
		val == target or
		(target - radius <= val and val <= target + radius)
	)
	
#get character position z coordinate, respecting jump
#z depends on air/ground and coefficient
func get_char_actual_z(char_node):
	var char_position = char_node.global_position
	#take current y if character is on the ground
	#if they jump y depends on where they jumped from
	var z = y2z(
		char_position.y if not char_node.is_in_air
		else char_node.last_preair_y
	)
	return z
	
func call0_if_present(node, action_name):
	if (node != null):
		if (node.has_method(action_name)):
			node.call(action_name)
	
func invoke_later(callback_owner, callback_name, seconds_delay = 1):
	if (seconds_delay <= 0):
		call0_if_present(callback_owner, callback_name)
	else: 
		var timer = Timer.new()
		timer.wait_time = seconds_delay
		timer.one_shot = true
		timer.connect(
			"timeout",  
			self, 
			"_call_later_remove_timer",
			[callback_owner, callback_name, timer]
		)
		add_child(timer)
		timer.start()
	
func _call_later_remove_timer(action_owner_node, action_name, timer_node):
	call0_if_present(action_owner_node, action_name)
	remove_child(timer_node)
	timer_node.queue_free()

#move specific physics collision layer bit for node 
# from from_layer to to_layer
func swap_collision_layer_bit(node, from_layer, to_layer):
	var temp_layer_bit = node.get_collision_layer_bit(from_layer)
	node.set_collision_layer_bit(from_layer, node.get_collision_layer_bit(to_layer))
	node.set_collision_layer_bit(to_layer, temp_layer_bit)
	
#move specific physics collision mask bit for node 
# from from_layer to to_layer
func swap_collision_mask_bit(node, from_layer, to_layer):
	var temp_mask_bit = node.get_collision_mask_bit(from_layer)
	node.set_collision_mask_bit(from_layer, node.get_collision_mask_bit(to_layer))
	node.set_collision_mask_bit(to_layer, temp_mask_bit)
	
func flip_facing(facing_direction):
	return C.FACING.LEFT if facing_direction == C.FACING.RIGHT else C.FACING.RIGHT
	
func get_facing_for_velocity(velocity):
	return sign(velocity)
	
func parse_json_file_as_var(filepath):
	#also sanity-checks string internally
	assert_file_exists(filepath)
	
	var file_handle = File.new()
	file_handle.open(filepath, file_handle.READ)
	var json_text = file_handle.get_as_text()
	var parse_result = JSON.parse(json_text)
	file_handle.close()
	
	if (parse_result.error == OK):
		return parse_result.result
	else:
		log_error("""
		JSON parse error!
		json: %s
		error code: %s
		error line: %s
		error message: %s""",
			[
				json_text,
				parse_result.error,
				parse_result.error_line,
				parse_result.error_string
			]
		)
	
#log formatted with timestamp
func logf(format, args_list = []):
	var log_statement = format % args_list
	#print log date in utc
	print("[%s UTC]: %s" % [format_date(OS.get_datetime(true)), log_statement])
	
#return supplied date_dict formatted as constants fromat string
func format_date(datetime_dict):
	return C.DATETIME_FORMAT % [
		datetime_dict.year,
		datetime_dict.month,
		datetime_dict.day,
		datetime_dict.hour,
		datetime_dict.minute,
		datetime_dict.second
	]
	
func log_error(format, args_list = [], error_text_prefix = "!!!ERROR!!!"):
	logf(error_text_prefix + " " + format, args_list)
	breakpoint

#check passed dict contains all required props and error if not
func assert_dict_props(dict = {}, props_names = []):
	if (dict == null or not dict.has_all(props_names)):
		log_error("%s doesnt contain all props names of %s", [dict, props_names])

func assert_arr_not_empty(arr = []):
	if (arr == null or arr.size() < 1):
		log_error("Array %s was null or empty!", [arr])
		
func assert_string_not_blank(string):
	if (string == null or string.empty() or (string.strip_edges()).empty()):
		log_error("Provided string %s was null or empty/blank!", [string])
		
func assert_file_exists(filepath):
	assert_string_not_blank(filepath)
	if (not File.new().file_exists(filepath)):
		log_error("Provided file path %s doesnt exist!", [filepath])
	
func _ready():
	randomize()
	print("Loaded global functions node F!")
	pass
