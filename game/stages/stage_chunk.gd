extends Node2D

var stage_chunk_bounds = Rect2()
var tileset
var chunk_idx = 0

var chunk_left
var chunk_right

func _ready():
	tileset = $tileset
	chunk_left = $chunk_left
	chunk_right = $chunk_right
	stage_chunk_bounds = F.get_tilemap_bounding_rect(tileset)
	
	S.connect_signal_to(S.SIGNAL_REBEL_MOUNT_MOPED, self, "switch_foot_rebel_to_moped_on_road")
	S.connect_signal_to(S.SIGNAL_REBEL_UNMOUNT_MOPED, self, "switch_moped_rebel_to_foot_on_sidewalk")
	S.connect_signal_to(S.SIGNAL_REBEL_JUMP_CURB_ON_MOPED, self, "move_moped_rebel_over_curb")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_body_entered_chunk_left(body):
	if (F.is_body_active_rebel(body)):
		if (_body_at_area_left(chunk_left, body)):
			#rebel entered this chunk
			S.emit_signal2(S.SIGNAL_REBEL_ENTERED_CHUNK, chunk_idx, C.FACING.RIGHT)
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
			S.emit_signal2(S.SIGNAL_REBEL_ENTERED_CHUNK, chunk_idx, C.FACING.LEFT)


func init_rebel_on_foot():
	_switch_rebel_node(rebel_on_moped_node, rebel_on_foot_node)
	
func init_rebel_on_moped():
	_switch_rebel_node(rebel_on_foot_node, rebel_on_moped_node)
	
func _switch_rebel_node(switch_from_rebel, switch_to_rebel):
	switch_from_rebel.disable()
	switch_to_rebel.enable()
	G.node_active_rebel = switch_to_rebel

func switch_foot_rebel_to_moped_on_road():
	var on_road_position = _get_highest_road_position_below_sidewalk(rebel_on_foot_node.global_position)
	rebel_on_moped_node.global_position = on_road_position
	init_rebel_on_moped()

func _get_highest_road_position_below_sidewalk(on_sidewalk_position):
	#find closest curb tile below and get global position of that
	return F.get_tileset_position_or_break(
		on_sidewalk_position,
		road_tileset,
		Vector2(0, curb_tileset.cell_size.y)
	)

func switch_moped_rebel_to_foot_on_sidewalk():
	var on_sidewalk_position = rebel_on_moped_node.global_position
	if (not _is_rebel_on_sidewalk()):
		on_sidewalk_position = _get_lowest_sidewalk_position_above_road(rebel_on_moped_node.global_position)
	rebel_on_foot_node.global_position = on_sidewalk_position
	init_rebel_on_foot()
	
func _is_rebel_on_sidewalk():
	var rebel_position = G.node_active_rebel.global_position
	var sidewalk_cell_idx = sidewalk_tileset.get_cellv(sidewalk_tileset.world_to_map(rebel_position))
	
	return sidewalk_cell_idx >= 0

func move_moped_rebel_over_curb():
	var otherside_position = Vector2()
	if (_is_rebel_on_sidewalk()):
		otherside_position = _get_highest_road_position_below_sidewalk(rebel_on_moped_node.global_position)
	else:
		otherside_position = _get_lowest_sidewalk_position_above_road(rebel_on_moped_node.global_position)
	
	rebel_on_moped_node.global_position = otherside_position
	
func _get_lowest_sidewalk_position_above_road(on_road_position):
	
	#find closes curb tile above and use a global position above it
	return F.get_tileset_position_or_break(
		on_road_position,
		sidewalk_tileset,
		Vector2(0, -road_tileset.cell_size.y)
	)
	
	
	
func _body_at_area_left(area, body):
	var area_shape_center_position = (
		area.get_node('collider').shape.global_position
	)
	return body.global_position.x < area_shape_center_position.x
