extends Node2D

onready var sidewalk_tileset = get_node("tileset/sidewalk")
onready var curb_tileset = get_node("tileset/curb")
onready var road_tileset = get_node("tileset/road")

var rebel_on_foot_node
var rebel_on_moped_node


var bounding_rects_to_tilemaps = {}


func _ready():
	G.node_current_stage_root = self
	rebel_on_foot_node = $rebel_on_foot
	rebel_on_moped_node = $rebel_on_moped
	
	for stage_chunk in get_nodes_in_group(C.GROUP_STAGE_CHUNK):
		
		var stage_maps = stage_chunk.get_node('tileset')
		var bounds = F.get_tilemap_bounding_rect(stage_maps)
		
		bounding_rects_to_tilemaps[bounds] = {
			'curb': stage_maps.get_node('curb'),
			'road': stage_maps.get_node('road'),
			'sidewalk': stage_maps.get_node('sidewalk')
		}
		
	
	init_rebel_on_moped()
	
func _physics_process(delta):
	pass
	
	
	
