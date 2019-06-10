extends "stage_chunk_base.gd"

var LOG = preload("res://globals/logger.gd").new(self)
var Bench = preload("res://stages/props/bench.tscn")
var BoundaryPillar = preload("res://stages/props/sidewalkblock.tscn")
var WhiteWorker = preload("res://enemy/citizens/white_worker/white_worker1.tscn")
var BlueCar = preload("res://enemy/transport/car_blue/car_blue1.tscn")

var stage_chunk_bounds = Rect2()
var tileset
var num_benches = 2

var road_tileset
var curb_tileset
var sidewalk_tileset


func _ready():
	#sensibly named logging 
	LOG.entity_name = '[%s]' % self.name
	LOG.entity_type_descriptor = ''
	chunk_edge_left = $chunk_left
	chunk_edge_right = $chunk_right
	#connect body signals after stage chunks are setup
	_connect_chunk_edge_signals()
	tileset = $tileset
	stage_chunk_bounds = F.get_tilemap_bounding_rect(tileset)
	LOG.info("Calculated chunk bounds: %s", [stage_chunk_bounds])
	road_tileset = $city_road_tiles
	curb_tileset = $city_sidewalk_tiles/city_tiles_curbs
	sidewalk_tileset = $city_sidewalk_tiles
	
	S.connect_signal_to(S.SIGNAL_REBEL_MOUNT_MOPED, self, "emit_closest_road_position")
	S.connect_signal_to(S.SIGNAL_REBEL_UNMOUNT_MOPED, self, "emit_closest_sidewalk_position")
	S.connect_signal_to(S.SIGNAL_REBEL_JUMP_CURB_ON_MOPED, self, "move_moped_rebel_over_curb")
	
	_generate_white_worker()
		
func _generate_white_worker():
	var potential_worker_positions = $prop_positions/citizens.get_children()
	var chosen_white_worker_position = F.get_rand_array_elem(potential_worker_positions)
	
	var worker = WhiteWorker.instance()
	worker.global_position = chosen_white_worker_position.global_position
	worker.stage_chunk_idx = chunk_idx
	worker.add_to_group(C.GROUP_CITIZENS)
	$chunk_props.add_child(worker)


func emit_closest_road_position():
	if (not _is_rebel_on_this_chunk()):
		return
	var rebel_position = G.node_active_rebel.global_position
	var closest_road_position = _get_highest_road_position_below_sidewalk(rebel_position)
	_emit_new_rebel_position(closest_road_position, C.REBEL_STATES.ON_MOPED)

func _get_highest_road_position_below_sidewalk(on_sidewalk_position):
	#find closest curb tile below and get global position of that
	return F.get_tileset_position_or_break(
		on_sidewalk_position,
		road_tileset,
		Vector2(0, curb_tileset.cell_size.y)
	)

func emit_closest_sidewalk_position():
	if (not _is_rebel_on_this_chunk()):
		return
	var rebel_position = G.node_active_rebel.global_position
	var closest_sidewalk_position = _get_lowest_sidewalk_position_above_road(rebel_position)
	_emit_new_rebel_position(closest_sidewalk_position, C.REBEL_STATES.ON_FOOT)
	
func _is_rebel_on_sidewalk():
	if (not _is_rebel_on_this_chunk()):
		return false
	var rebel_position = G.node_active_rebel.global_position
	var sidewalk_cell_idx = sidewalk_tileset.get_cellv(sidewalk_tileset.world_to_map(rebel_position))
	
	return sidewalk_cell_idx >= 0
	
func _is_rebel_on_this_chunk():
	return G.rebel_current_stage_chunk_idx == chunk_idx

func move_moped_rebel_over_curb():
	if (_is_rebel_on_this_chunk()):	
		var otherside_position = Vector2()
		var rebel_position = G.node_active_rebel.global_position
		if (_is_rebel_on_sidewalk()):
			otherside_position = _get_highest_road_position_below_sidewalk(rebel_position)
		else:
			otherside_position = _get_lowest_sidewalk_position_above_road(rebel_position)
		_emit_new_rebel_position(otherside_position)
		
	
func _emit_new_rebel_position(new_position, for_rebel_state = G.active_rebel_state):
	S.emit_signal2(
		S.SIGNAL_REBEL_CHANGED_POSITION, 
		new_position, 
		for_rebel_state
	)

func _get_lowest_sidewalk_position_above_road(on_road_position):
	#find closes curb tile above and use a global position above it
	return F.get_tileset_position_or_break(
		on_road_position,
		sidewalk_tileset,
		Vector2(0, -road_tileset.cell_size.y)
	)
	
func generate_car(parent, facing):
	LOG.info("generating new car facing %s", [facing])
	var car_start_position
	if (facing == C.FACING.LEFT):
		car_start_position = $car_go_left_start.global_position
	else:
		car_start_position = $car_go_right_start.global_position
	var new_car = BlueCar.instance()
	new_car.global_position = car_start_position
	new_car.maintains_direction = Vector2(facing, 0)
	parent.add_child(new_car)
