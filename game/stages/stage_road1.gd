extends "stage_base.gd"

var CityMiddleChunk = preload("res://stages/city1middle_road1.tscn")

var rebel_on_foot_node
var rebel_on_moped_node


func _ready():
	LOG = Logger.new(self.name)
	G.node_current_stage_root = self
	rebel_on_foot_node = $sorted_sprites/rebel_on_foot
	rebel_on_moped_node = $sorted_sprites/rebel_on_moped
	G.node_rebel_on_moped = rebel_on_moped_node
	G.node_rebel_on_foot = rebel_on_foot_node
	G.node_active_rebel = G.node_rebel_on_foot
	#save for more targeted adding of new chunks
	last_added_chunk_node = $city1middle_road3
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
	
	rebel_on_moped_node.disable()
	init_rebel_on_moped()
	
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
	
func _get_append_chunk_scene():
	return CityMiddleChunk
	
func _body_entered_chunk(body, chunk_idx, facing):
	._body_entered_chunk(body, chunk_idx, facing)
	if (F.is_body_active_rebel(body)):
		var spawn_car_chance = randf()
		if (0.33 <= spawn_car_chance and spawn_car_chance <= 0.66):
			_try_generate_car_behind(chunk_idx, facing)
		elif (spawn_car_chance > 0.66):
			_try_generate_car_infront(chunk_idx, facing)
			
func _try_generate_car_behind(current_chunk_idx, facing):
	if (_is_edge_chunk_for_facing(current_chunk_idx, facing)):
		return
	var offset = -2 if facing == C.FACING.RIGHT else 2
	_add_car_to_chunk_offset(current_chunk_idx, offset, facing)

func _add_car_to_chunk_offset(current_chunk_idx, offset, facing):
	var chunk_idx_offset = clamp(current_chunk_idx + offset, 0, curr_added_chunks.size() - 1)
	var chunk_node = curr_added_chunks[chunk_idx_offset]
	if (chunk_node.has_method("generate_car")):
		chunk_node.generate_car($sorted_sprites, facing)
		
func _try_generate_car_infront(current_chunk_idx, facing):
	if (_is_edge_chunk_for_facing(current_chunk_idx, facing)):
		return
	var offset = -2 if facing == C.FACING.LEFT else 2
	_add_car_to_chunk_offset(current_chunk_idx, offset, F.flip_facing(facing))

func _is_edge_chunk_for_facing(chunk_idx, facing):
	return (
	(chunk_idx == 0 and facing == C.FACING.RIGHT)
		or (chunk_idx == curr_added_chunks.size() - 1 and facing == C.FACING.LEFT)
	)
	
