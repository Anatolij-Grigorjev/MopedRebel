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
	
func get_N_rand_array_elems(N = 1, array = []):
	if (N == 1):
		return get_rand_array_elem(array)
	if (array == null or array.empty()):
		return null
	if (N >= array.size()):
		return array
	#search defensively with array copy
	var array_indices = range(array.size())
	var rand_list = []
	for iter_idx in range(N):
		var rand_idx = get_rand_array_elem(array_indices)
		array_indices.erase(rand_idx)
		rand_list.append(array[rand_idx])
		
	return rand_list
	
func is_anim_playing(player_node, anim_name):
	return player_node.is_playing() and player_node.current_animation == anim_name
	
func get_node_collision_layer_state(node, num_bits = C.NUM_COLLISION_BITS):
	var current_state = []
	current_state.resize(num_bits)
	for idx in range(0, current_state.size()):
		current_state[idx] = node.get_collision_layer_bit(idx)
	return current_state
	
func set_node_collision_layer_bits(node, value, which_bits = []):
	#if no specifics then do all bits
	if (which_bits.empty()):
		which_bits = range(0, C.NUM_COLLISION_BITS)
	for idx in which_bits:
		node.set_collision_layer_bit(idx, value)
	
func get_absolute_for_coef(coef, abs_max, abs_min = 0):
	var abs_range = abs_max - abs_min
	var delta = coef * abs_range
	return abs_min + delta
	
func get_coef_for_absolute(abs_value, abs_max, abs_min = 0):
	var abs_range = abs_max - abs_min
	return (abs_value - abs_min) / abs_range
	
func get_elapsed_timer_time(timer):
	if (timer.is_stopped()):
		return 0.0
	else:
		return timer.wait_time - timer.time_left
	
#check if value is in radius of target with a short circuit if equal
func is_val_in_target_radius(val, target, radius):
	return (
		val == target or
		(target - radius <= val and val <= target + radius)
	)
	
#checks node for equality against currently cached global
#game state rebels
func is_node_rebel(node):
	return (
		node == G.node_rebel_on_foot 
		or node == G.node_rebel_on_moped
	)
	
func get_tileset_position_or_break(start_position, target_tileset, increment, max_increments = 10):
	var initial_search = get_first_position_on_target_tileset(start_position, target_tileset, increment, max_increments)
	#if position found all good
	if (initial_search[0]):
		return initial_search[1]
	else:
		log_error("Could not find position on tileset %s after %s increments of %s starting from %s", [
			get_node_name_safe(target_tileset),
			max_increments,
			increment,
			start_position
		])


func get_tilemap_bounding_rect(tilemap):
	if (tilemap == null):
		return Rect2()
	
	var tilemap_cells = tilemap.get_used_cells()
	if (tilemap_cells == null or tilemap_cells.empty()):
		return Rect2()
		
	var first_cell = tilemap_cells[0]
	var low_x = first_cell.x
	var low_y = first_cell.y
	var high_x = low_x
	var high_y = low_y
	
	for cell_idx in range(1, tilemap_cells.size()):
		var a_cell_pos = tilemap_cells[cell_idx]
		
		#check X
		if (a_cell_pos.x < low_x):
			low_x = a_cell_pos.x
		elif (a_cell_pos.x > high_x):
			high_x = a_cell_pos.x
			
		#check Y
		if (a_cell_pos.y < low_y):
			low_y = a_cell_pos.y
		elif (a_cell_pos.y > high_y):
			high_y = a_cell_pos.y
	
	var cell_extents = tilemap.get_cell_size() / 2
	
	var lowest_global = tilemap.map_to_world(Vector2(low_x, low_y)) - cell_extents
	var highest_global = tilemap.map_to_world(Vector2(high_x, high_y)) + cell_extents
	
	return Rect2(
		#x/y vector
		lowest_global,
		#w/h vector
		(highest_global - lowest_global)
	)
	
#check if this node is actually the active rebel node
func is_body_active_rebel(body):
	return (
		typeof(body) == typeof(G.node_active_rebel)
		and body == G.node_active_rebel
	)
	
func set_active_rebel_state(new_rebel_state):
	if (new_rebel_state != G.active_rebel_state):
		G.node_active_rebel.disable() 
	G.active_rebel_state = new_rebel_state
	if (new_rebel_state == C.REBEL_STATES.ON_FOOT):
		G.node_active_rebel = G.node_rebel_on_foot
	else:
		G.node_active_rebel = G.node_rebel_on_moped
	G.node_active_rebel.enable()
		
func is_rebel_state(rebel_state):
	return G.active_rebel_state == rebel_state
	
func is_rebel_on_sidewalk():
	return (
		is_rebel_state(C.REBEL_STATES.ON_FOOT) 
		or G.node_rebel_on_moped.moped_ground_type == G.node_rebel_on_moped.MOPED_GROUND_TYPES.SIDEWALK
	)


#starting from start_position, keep adding the "increment" vector
#max_increment tries to find a global_position that 
#belongs to a tile on the tileset target_tileset
#returns flag of pos found/not and calculated position
func get_first_position_on_target_tileset(start_position, target_tileset, increment = Vector2(), max_increments = 10):
	var num_increments = 0
	var target_tileset_position = start_position
	#before doing any looping check if already on target tileset
	var target_tileset_cell_idx = target_tileset.get_cellv(target_tileset.world_to_map(target_tileset_position))
	while(target_tileset_cell_idx < 0 and num_increments < max_increments):
		max_increments += 1
		target_tileset_position += increment
		target_tileset_cell_idx = target_tileset.get_cellv(target_tileset.world_to_map(target_tileset_position))
	
	var was_position_found = target_tileset_cell_idx >= 0
	return [was_position_found, target_tileset_position]
	
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
	
func get_speed_to_active_rebel_direction(node, speed = 1):
	assert_not_null(node)
	var rebel_position = G.node_active_rebel.global_position
	var rebel_direction = (rebel_position - node.global_position).normalized()
	return speed * rebel_direction
	
func call0_if_present(node, action_name):
	logf("invoking action %s on node %s", [
		action_name,
		get_node_name_safe(node)
	])
	if (node != null):
		if (node.has_method(action_name)):
			node.call(action_name)

func get_node_name_safe(node):
	if (node != null && node.has_method("get_name")):
		return node.name
	else:
		return "<NULL>"
	
func invoke_later(node_owner, action_name, seconds_delay = 1):
	if (seconds_delay <= 0):
		call0_if_present(node_owner, action_name)
	else: 
		logf("requested to call %s on %s in %s seconds...", [
			action_name, 
			get_node_name_safe(node_owner), 
			seconds_delay
		])
		# Wait seconds_delay seconds, then resume execution.
		yield(get_tree().create_timer(seconds_delay), "timeout")
		call0_if_present(node_owner, action_name)

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
	
func is_rebel_in_area(area_node):
	if (area_node == null):
		return false
	return area_node.overlaps_body(G.node_active_rebel)
	
func get_facing_for_velocity(velocity):
	if (typeof(velocity) == TYPE_VECTOR2):
		return sign(velocity.x)
	else: 
		return sign(velocity)
		
func add_facing_to_string(facing, prefix_string):
	var result = prefix_string
	if (facing == C.FACING.RIGHT):
		result += "_right"
	else:
		result += "_left"
	return result
	
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
	
#log formatted with timestamp, avoid using directly since 
#logger.gd is a thing!
func logf(format, args_list = []):
	var log_statement = format % args_list
	#print log date in utc
	print("[%s UTC] %s" % [format_date(OS.get_datetime(true)), log_statement])
	
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
	if (arr == null or (typeof(arr) < TYPE_ARRAY) or arr.size() < 1):
		log_error("%s was null or NOT an Array or empty!", [arr])
		
func assert_string_not_blank(string):
	if (string == null or string.empty() or (string.strip_edges()).empty()):
		log_error("Provided string %s was null or empty/blank!", [string])

func assert_not_null(thing):
	if (thing == null):
		log_error("Supplied value was null!")

func assert_is_true(condition, false_error_message):
	if (not condition):
		log_error(false_error_message)
		
func assert_file_exists(filepath):
	assert_string_not_blank(filepath)
	if (not File.new().file_exists(filepath)):
		log_error("Provided file path %s doesnt exist!", [filepath])
	
func _ready():
	randomize()
	print("Loaded global functions node F!")
	pass
