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
