extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG
var ShoutPopup = preload("res://common/shout_popup.tscn")
var OffscreenAction = preload("res://common/action_after_offscreen.tscn")

var curr_num_chunks = 0
var last_added_chunk_node
var next_chunk_position = Vector2()

var curr_added_chunks = []

func _ready():
	
	S.connect_signal_to(S.SIGNAL_BODY_LEAVING_CHUNK, self, "_body_leaving_chunk")
	S.connect_signal_to(S.SIGNAL_BODY_ENTERING_CHUNK, self, "_body_entering_chunk")
	S.connect_signal_to(S.SIGNAL_BODY_ENTERED_CHUNK, self, "_body_entered_chunk")
	S.connect_signal_to(S.SIGNAL_BODY_LEFT_CHUNK, self, "_body_left_chunk")
	pass

func _body_leaving_chunk(body, chunk_idx, facing):
	LOG.info("body %s LEAVING chunk %s, facing %s", [body.name, chunk_idx, facing])
	if (F.is_body_active_rebel(body)):
		_rebel_leaving_chunk(chunk_idx, facing)
	
func _rebel_leaving_chunk(chunk_idx, rebel_facing):
	#rebel facing right and leaving so must be headed right
	if (rebel_facing == C.FACING.RIGHT):
		#running out of chunks for rebel
		if (chunk_idx + 2 >= curr_num_chunks):
			LOG.info("rebel leaving chunk %s, total was %s so adding more chunks!", [chunk_idx, curr_num_chunks])
			var AppendChunkType = _get_append_chunk_scene()
			if (AppendChunkType != null):
				_append_stage_chunk_right(AppendChunkType)
			else:
				LOG.warn("Next chunk to append returned null, stage over!")
			
func _get_append_chunk_scene():
	LOG.warn("override _get_append_chunk_scene to add chunks to stage!")
	return null
	
func _append_stage_chunk_right(ChunkType):
	var new_chunk = ChunkType.instance()
	add_child_below_node(last_added_chunk_node, new_chunk)
	new_chunk.global_position = next_chunk_position
	new_chunk.add_to_group(C.GROUP_STAGE_CHUNK)
	_index_new_chunk(new_chunk)
	
func _index_new_chunk(chunk_node):
	var stage_maps = chunk_node.get_node('tileset')
	var bounds = F.get_tilemap_bounding_rect(stage_maps)
	bounds.position = chunk_node.global_position
	next_chunk_position = bounds.position + Vector2(bounds.size.x, 0)
	LOG.info("next chunk position will be: %s", [next_chunk_position])
	chunk_node.chunk_idx = curr_added_chunks.size()
	curr_added_chunks.append(chunk_node)
	LOG.info('New chunks total: %s', [curr_added_chunks.size()])
	
func _body_left_chunk(body, chunk_idx, facing):
	LOG.info("body %s LEFT chunk %s, facing %s", [body.name, chunk_idx, facing])
	#did the body drive offscreen on the left
	#rebel gets turned around, enemy gets scrapped
	if (facing == C.FACING.LEFT and chunk_idx == 0):
		if (F.is_body_active_rebel(body)):
			_turn_around_offscreen_rebel(facing)
		else:
			_attach_body_offscreen_free(body)
	
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
	
func _attach_body_offscreen_free(body):
	var offscreen_actor = OffscreenAction.instance()
	#by default actor will queue_free owner node after 1 second
	body.add_child(offscreen_actor)
	
func _body_entering_chunk(body, chunk_idx, facing):
	LOG.info("body %s ENTERING chunk %s, facing %s", [body.name, chunk_idx, facing])
	pass

func _body_entered_chunk(body, chunk_idx, facing):
	LOG.info("body %s ENTERED chunk %s, facing %s", [body.name, chunk_idx, facing])
