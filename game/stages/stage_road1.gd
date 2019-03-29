extends Node2D

var rebel_on_foot_node
var rebel_on_moped_node

func _ready():
	G.node_current_stage_root = self
	rebel_on_foot_node = $rebel_on_foot
	rebel_on_moped_node = $rebel_on_moped
	S.connect_signal_to(S.SIGNAL_REBEL_MOUNT_MOPED, self, "switch_foot_rebel_to_moped_on_road")
	S.connect_signal_to(S.SIGNAL_REBEL_UNMOUNT_MOPED, self, "switch_moped_rebel_to_foot_on_sidewalk")
	S.connect_signal_to(S.SIGNAL_REBEL_JUMP_CURB_ON_MOPED, self, "move_moped_rebel_to_sidewalk")
	
	init_rebel_on_foot()


func init_rebel_on_foot():
	_switch_rebel_node(rebel_on_moped_node, rebel_on_foot_node)
	
func init_rebel_on_moped():
	_switch_rebel_node(rebel_on_foot_node, rebel_on_moped_node)
	
func _switch_rebel_node(switch_from_rebel, switch_to_rebel):
	switch_from_rebel.disable()
	switch_to_rebel.enable()
	switch_to_rebel.get_node('camera').current = true
	G.node_active_rebel = switch_to_rebel

func switch_foot_rebel_to_moped_on_road():
	var on_road_position = _get_highest_road_position_below_sidewalk(rebel_on_foot_node.global_position)
	rebel_on_moped_node.global_position = on_road_position
	init_rebel_on_moped()

func _get_highest_road_position_below_sidewalk(on_sidewalk_position):
	#find closest curb tile below and get global position of that
	var increment = $sidewalk_tileset.cell_size.y
	var curb_cell_idx = -1
	var below_position = on_sidewalk_position
	while(curb_cell_idx < 0 and below_position.y < C.MAX_WORLD_Y):
		below_position += Vector2(0, increment)
		curb_cell_idx = $curb_tileset.get_cellv($curb_tileset.world_to_map(below_position))
	
	var on_road_position = below_position + Vector2(0, $curb_tileset.cell_size.y)
	return on_road_position

func switch_moped_rebel_to_foot_on_sidewalk():
	var on_sidewalk_position = _get_lowest_sidewalk_position_above_road(rebel_on_moped_node.global_position)
	rebel_on_foot_node.global_position = on_sidewalk_position
	init_rebel_on_foot()

func move_moped_rebel_to_sidewalk():
	var on_sidewalk_position = _get_lowest_sidewalk_position_above_road(rebel_on_moped_node.global_position)
	rebel_on_moped_node.global_position = on_sidewalk_position
	
func _get_lowest_sidewalk_position_above_road(on_road_position):
	#find closes curb tile above and use a global position above it
	var increment = $road_tileset.cell_size.y
	var curb_cell_idx = -1
	var above_position = on_road_position
	while(curb_cell_idx < 0 and above_position.y > 0):
		above_position -= Vector2(0, increment)
		curb_cell_idx = $curb_tileset.get_cellv($curb_tileset.world_to_map(above_position))
	
	var on_sidewalk_position = above_position - Vector2(0, $curb_tileset.cell_size.y)
	return on_sidewalk_position
	
func _physics_process(delta):
	pass
	
	
	
