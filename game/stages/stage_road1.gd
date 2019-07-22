extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG

var stage_size = Vector2(3600, 900)

enum REBEL_STATE {
	ON_FOOT,
	ON_MOPED
}
export(REBEL_STATE) var initial_rebel_state = REBEL_STATE.ON_MOPED

func _ready():
	LOG = Logger.new(self.name)
	G.node_current_stage_root = self
	#initialize node switch context
	if (initial_rebel_state == REBEL_STATE.ON_MOPED):
		G.node_active_rebel = G.node_rebel_on_foot
		G.node_rebel_on_moped.disable()
		F.set_active_rebel_state(C.REBEL_STATES.ON_MOPED)
	elif (initial_rebel_state == REBEL_STATE.ON_FOOT):
		G.node_active_rebel = G.node_rebel_on_foot
		G.node_rebel_on_moped.disable()
		F.set_active_rebel_state(C.REBEL_STATES.ON_FOOT)
	else:
		LOG.error("Unknown initial rebel state %s!", [initial_rebel_state])
	
	
func _rebel_new_position_state_received(new_rebel_position, for_rebel_state):
	if (not F.is_rebel_state(for_rebel_state)):
		F.set_active_rebel_state(for_rebel_state)
	G.node_active_rebel.global_position = new_rebel_position
	
func _change_moped_parent(moped_road_type):
	var new_parent = null
	match(moped_road_type):
		C.MOPED_GROUND_TYPES.ROAD:
			new_parent = $city_road_tiles
		C.MOPED_GROUND_TYPES.SIDEWALK:
			new_parent = $city_sidewalk_tiles/city_benches
		_:
			LOG.error("unknown moped ground type: %s", [moped_road_type])
	F.assert_not_null(new_parent)
	LOG.info("setting moped to parent %s on gorund %s", [new_parent, moped_road_type])
	F.reparent_node(G.node_rebel_on_moped, new_parent)	
	
