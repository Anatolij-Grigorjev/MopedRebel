extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG
var ShoutPopup = preload("res://common/shout_popup.tscn")
var CityMiddleChunk = preload("res://stages/city1middle_road1.tscn")

var rebel_on_foot_node
var rebel_on_moped_node

var curr_num_chunks = 0
var next_chunk_position = Vector2()


func _ready():
	LOG = Logger.new(self.name)
	G.node_current_stage_root = self
	rebel_on_foot_node = $sorted_sprites/rebel_on_foot
	rebel_on_moped_node = $sorted_sprites/rebel_on_moped
	G.node_rebel_on_moped = rebel_on_moped_node
	G.node_rebel_on_foot = rebel_on_foot_node
	G.node_active_rebel = G.node_rebel_on_foot
	
	for stage_chunk in get_tree().get_nodes_in_group(C.GROUP_STAGE_CHUNK):
		
		_index_new_chunk(stage_chunk)

		#put all stage chunk props/enemies into YSORT thing
		var active_props = stage_chunk.get_node('chunk_props').get_children()
		for active_prop in active_props:
			if (active_prop.get_parent() != null):
				var prev_parent = active_prop.get_parent()
				prev_parent.remove_child(active_prop)
			$sorted_sprites.add_child(active_prop)
			active_prop.set_owner($sorted_sprites)
	
	S.connect_signal_to(S.SIGNAL_REBEL_CHANGED_POSITION, self, "_rebel_new_position_state_received")
	S.connect_signal_to(S.SIGNAL_REBEL_LEAVING_CHUNK, self, "_rebel_leaving_chunk")
	S.connect_signal_to(S.SIGNAL_REBEL_ENTERING_CHUNK, self, "_rebel_entering_chunk")
	
	rebel_on_moped_node.disable()
	init_rebel_on_moped()
	
func _index_new_chunk(chunk_node):
	var stage_maps = chunk_node.get_node('tileset')
	var bounds = F.get_tilemap_bounding_rect(stage_maps)
	bounds.position += chunk_node.global_position
	next_chunk_position = bounds.position + Vector2(bounds.size.x, 0)
	LOG.info("next chunk position will be: %s", [next_chunk_position])
	chunk_node.chunk_idx = curr_num_chunks
	curr_num_chunks += 1
	LOG.info('New chunks total: %s', [curr_num_chunks])
	
func init_rebel_on_foot():
	_switch_rebel_node(rebel_on_moped_node, rebel_on_foot_node)
	
func init_rebel_on_moped():
	_switch_rebel_node(rebel_on_foot_node, rebel_on_moped_node)
	
func _switch_rebel_node(switch_from_rebel, switch_to_rebel):
	var new_state = C.REBEL_STATES.ON_FOOT
	if (switch_to_rebel == G.node_rebel_on_moped):
		new_state = C.REBEL_STATES.ON_MOPED
	F.set_active_rebel_state(new_state)
	
func _rebel_new_position_state_received(new_rebel_position, for_rebel_state):
	if (not F.is_rebel_state(for_rebel_state)):
		F.set_active_rebel_state(for_rebel_state)
	G.node_active_rebel.global_position = new_rebel_position
	
func _rebel_leaving_chunk(chunk_idx, rebel_facing):
	LOG.info("rebel LEAVING chunk %s, facing %s", [chunk_idx, rebel_facing])
	#rebel facing right and leaving so must be headed right
	if (rebel_facing == C.FACING.RIGHT):
		#running out of chunks for rebel
		if (chunk_idx + 2 > curr_num_chunks):
			_append_stage_chunk_right(CityMiddleChunk)
	pass
	
func _append_stage_chunk_right(ChunkType):
	var new_chunk = ChunkType.instance()
	add_child(new_chunk)
	new_chunk.global_position = next_chunk_position
	new_chunk.add_to_group(C.GROUP_STAGE_CHUNK)
	_index_new_chunk(new_chunk)
	
func _rebel_entering_chunk(chunk_idx, rebel_facing):
	LOG.info("rebel ENTERING chunk %s, facing %s", [chunk_idx, rebel_facing])
	pass
	
func _turn_around_offscreen_rebel(rebel_facing):
	LOG.info('rebel went offscreen long enough, turning around...')
	
	var rebel_node = G.node_active_rebel
	rebel_node.control_locked = true
	
	#which direction rebel should face to comeback onscreen
	var new_facing = F.flip_facing(rebel_facing)
	
	#turn around rebel on moped in case its still facing wrong way
	if (F.is_rebel_state(C.REBEL_STATES.ON_MOPED)
		and rebel_node.facing_direction != new_facing):
		rebel_node._turn_around_moped()
		
	var comeback_speed = 0
	if (F.is_rebel_state(C.REBEL_STATES.ON_MOPED)):
		var average_moped_speed = G.moped_config_min_speed + ((G.moped_config_max_speed - G.moped_config_min_speed) / 2)
		rebel_node.current_speed = average_moped_speed
		comeback_speed = average_moped_speed
	else:
		var walk_speed = G.foot_config_walk_speed
		rebel_node.velocity = Vector2(walk_speed * new_facing, 0)
		comeback_speed = walk_speed
	#amount of time it will take to drive back
	var time_back = (100 + abs(rebel_node.global_position.x)) / comeback_speed
	#give back control once onscreen
	F.invoke_later(self, '_restore_rebel_control', time_back)
	#make manager shout
	var manager_line = PE._get_random_common_phrase(PE.PHRASE_TYPES.MANAGER)
	_show_shout_dialog(manager_line, time_back)
	
func _show_shout_dialog(shout_line, for_seconds):
	var shout_dialog = ShoutPopup.instance()
	shout_dialog.shout_line = shout_line
	shout_dialog.visible_time = for_seconds
	add_child(shout_dialog)
	shout_dialog.show_popup()
	

func _restore_rebel_control():
	G.node_active_rebel.control_locked = false
	
	
