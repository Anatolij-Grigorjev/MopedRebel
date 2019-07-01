extends "stage_base.gd"

var rebel_on_foot_node
var rebel_on_moped_node


func _ready():
	LOG = Logger.new(self.name)
	G.node_current_stage_root = self
	rebel_on_foot_node = $city_sidewalk_tiles/city_benches/rebel_on_foot
	rebel_on_moped_node = $city_road_tiles/rebel_on_moped
	G.node_rebel_on_moped = rebel_on_moped_node
	G.node_rebel_on_foot = rebel_on_foot_node
	G.node_active_rebel = G.node_rebel_on_foot
	
	S.connect_signal_to(S.SIGNAL_REBEL_CHANGED_POSITION, self, "_rebel_new_position_state_received")
	
	F.set_active_rebel_state(C.REBEL_STATES.ON_MOPED)
	
	
func _rebel_new_position_state_received(new_rebel_position, for_rebel_state):
	if (not F.is_rebel_state(for_rebel_state)):
		F.set_active_rebel_state(for_rebel_state)
	G.node_active_rebel.global_position = new_rebel_position
