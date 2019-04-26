extends Node2D

var LOG = preload("res://globals/logger.gd").new(self)
var Bench = preload("res://stages/props/bench.tscn")
var WhiteWorker = preload("res://enemy/citizens/white_worker/white_worker1.tscn")

var stage_chunk_bounds = Rect2()
var tileset
var chunk_idx = 0
var num_benches = 2

var chunk_left
var chunk_right

var road_tileset
var curb_tileset
var sidewalk_tileset


func _ready():
	tileset = $tileset
	chunk_left = $chunk_left
	chunk_right = $chunk_right
	stage_chunk_bounds = F.get_tilemap_bounding_rect(tileset)
	LOG.info("Calculated chunk bounds: %s", [stage_chunk_bounds])
	road_tileset = $tileset/road
	curb_tileset = $tileset/curb
	sidewalk_tileset = $tileset/sidewalk
	
	S.connect_signal_to(S.SIGNAL_REBEL_MOUNT_MOPED, self, "emit_closest_road_position")
	S.connect_signal_to(S.SIGNAL_REBEL_UNMOUNT_MOPED, self, "emit_closest_sidewalk_position")
	S.connect_signal_to(S.SIGNAL_REBEL_JUMP_CURB_ON_MOPED, self, "move_moped_rebel_over_curb")
	
	_generate_random_benches()
	_generate_white_worker()

func _generate_random_benches():
	var potential_bench_positions = $prop_positions/benches.get_children()
	var bench_positions = F.get_N_rand_array_elems(
		num_benches,
		potential_bench_positions
	)
	for position in bench_positions:
		var bench = Bench.instance()
		bench.global_position = position.global_position
		bench.add_to_group(C.GROUP_PROPS)
		$chunk_props.add_child(bench)
		
func _generate_white_worker():
	var potential_worker_positions = $prop_positions/citizens.get_children()
	var chosen_white_worker_position = F.get_rand_array_elem(potential_worker_positions)
	
	var worker = WhiteWorker.instance()
	worker.global_position = chosen_white_worker_position.global_position
	worker.add_to_group(C.GROUP_CITIZENS)
	$chunk_props.add_child(worker)


func _on_body_entered_chunk_left(body):
	if (F.is_body_active_rebel(body)):
		if (_body_at_area_left(chunk_left, body)):
			#rebel entered this chunk
			S.emit_signal2(S.SIGNAL_REBEL_ENTERING_CHUNK, chunk_idx, C.FACING.RIGHT)
		else:
			#rebel exiting chunk
			S.emit_signal2(S.SIGNAL_REBEL_LEAVING_CHUNK, chunk_idx, C.FACING.LEFT)


func _on_body_entered_chunk_right(body):
	if (F.is_body_active_rebel(body)):
		if (_body_at_area_left(chunk_right, body)):
			#rebel exiting chunk
			S.emit_signal2(S.SIGNAL_REBEL_LEAVING_CHUNK, chunk_idx, C.FACING.RIGHT)
		else:
			#rebel entered this chunk
			S.emit_signal2(S.SIGNAL_REBEL_ENTERING_CHUNK, chunk_idx, C.FACING.LEFT)


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
	
	
	
func _body_at_area_left(area, body):
	var area_collider = area.get_node('collider')
	var area_shape_center_position = (
		area_collider.global_position + 
		area_collider.shape.extents
	)
	return body.global_position.x < area_shape_center_position.x
