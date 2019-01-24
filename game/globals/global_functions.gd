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
	
#check if value is in radius of target with a short circuit if equal
func val_in_target_radius(val, target, radius):
	return (
		val == target or 
		(target - radius <= val and val <= target + radius)
	)
	
#get character position z coordinate, respecting jump
#z depends on air/ground and coefficient
func char_actual_z(char_node):
	var char_position = char_node.global_position
	#take current y if character is on the ground
	#if they jump y depends on where they jumped from
	var z = y2z(
		char_position.y if not char_node.is_in_air 
		else char_node.last_preair_y
	)
	return z
	

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
	if (not dict.has_all(props_names)):
		log_error("%s doesnt contain all props names of %s", [dict, props_names])

func assert_arr_not_empty(arr = []):
	if (arr == null or arr.size() < 1):
		log_error("Array %s was null or empty!", [arr])

func _ready():
	print("Loaded global functions node F!")
	pass
