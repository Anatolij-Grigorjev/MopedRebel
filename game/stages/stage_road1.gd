extends Node2D

var rebel_on_foot_node
var rebel_on_moped_node


func _ready():
	rebel_on_foot_node = $rebel_on_foot
	rebel_on_moped_node = $rebel_on_moped
	S.connect_signal_to(S.SIGNAL_REBEL_MOUNT_MOPED, self, "move_foot_rebel_to_road")
	
	init_rebel_on_foot()


func init_rebel_on_foot():
	switch_rebel_node(rebel_on_moped_node, rebel_on_foot_node)
	
func init_rebel_on_moped():
	switch_rebel_node(rebel_on_foot_node, rebel_on_moped_node)

	
func move_foot_rebel_to_road():
	#find closest curb tile below and get global position of that
	var increment = $sidewalk_tileset.cell_size.y
	var curb_cell_idx = -1
	var below_position = rebel_on_foot_node.global_position
	while(curb_cell_idx < 0):
		below_position += Vector2(0, increment)
		curb_cell_idx = $curb_tileset.get_cellv($curb_tileset.world_to_map(below_position))
	
	var on_road_position = below_position + Vector2(0, $curb_tileset.cell_size.y)
	rebel_on_moped_node.global_position = on_road_position
	init_rebel_on_moped()
	
	
func switch_rebel_node(switch_from_rebel, switch_to_rebel):
	switch_from_rebel.disable()
	switch_to_rebel.enable()
	switch_to_rebel.get_node('camera').current = true
	
	
	
