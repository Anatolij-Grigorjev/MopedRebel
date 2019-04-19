extends Node2D

var LOG = preload("res://globals/logger.gd").new(self)

var rebel_on_foot_node
var rebel_on_moped_node


var bounding_rects_to_tilemaps = {}


func _ready():
	G.node_current_stage_root = self
	rebel_on_foot_node = $rebel_on_foot
	rebel_on_moped_node = $rebel_on_moped
	G.node_rebel_on_moped = rebel_on_moped_node
	G.node_rebel_on_foot = rebel_on_foot_node
	G.node_active_rebel = G.node_rebel_on_foot
	
	
	var latest_chunk_idx = 0
	
	for stage_chunk in get_tree().get_nodes_in_group(C.GROUP_STAGE_CHUNK):
		
		var stage_maps = stage_chunk.get_node('tileset')
		var bounds = F.get_tilemap_bounding_rect(stage_maps)
		bounds.position += stage_chunk.global_position
		
		stage_chunk.chunk_idx = latest_chunk_idx
		latest_chunk_idx += 1
		
		LOG.info("bounds for chunk %s: %s", [stage_chunk.name, bounds])
		bounding_rects_to_tilemaps[bounds] = {
			'curb': stage_maps.get_node('curb'),
			'road': stage_maps.get_node('road'),
			'sidewalk': stage_maps.get_node('sidewalk')
		}
	
	S.connect_signal_to(S.SIGNAL_REBEL_CHANGED_POSITION, self, "_rebel_new_position_state_received")
	S.connect_signal_to(S.SIGNAL_REBEL_LEAVING_CHUNK, self, "_rebel_leaving_chunk")
	S.connect_signal_to(S.SIGNAL_REBEL_ENTERING_CHUNK, self, "_rebel_entering_chunk")
	
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
	
func _rebel_leaving_chunk(chunk_idx, rebel_facing):
	pass
	
func _rebel_entering_chunk(chunk_idx, rebel_facing):
	pass
	
func _physics_process(delta):
	pass
	
	
	
