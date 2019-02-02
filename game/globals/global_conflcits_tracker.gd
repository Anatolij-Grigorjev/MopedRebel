extends Node2D

var conflict_node_scene = preload("res://conflict/conflict_root.tscn")

var conflict_rebel = null
var conflict_other = null
var active_conflict_node = null

func _ready():
	S.connect_signal_to(
		S.SIGNAL_REBEL_START_CONFLICT, 
		self, 
		"_init_rebel_other_conflict_screen"
	)
	S.connect_signal_to(
		S.SIGNAL_CONFLICT_RESOLVED,
		self,
		"_finish_conflict_state"
	)
	print("Loaded gloal conflict tracker node VS!")

func _init_rebel_other_conflict_screen(bribe_money, diss_min_sc, fight_toughness):
	var conflict_root = _attach_conflict_to_stage()
	var conflict_options_node = conflict_root.get_node('outer_container/selection_bgcolor/selection_bg/selection_options')
	conflict_options_node.init_conflict_with_details(bribe_money, diss_min_sc, fight_toughness)
	#prepare conflict camera
	var conflict_camera = conflict_root.get_node('camera')
	conflict_root.rect_size = get_viewport_rect().size
	conflict_camera.current = true
	conflict_camera.align()
	get_tree().paused = true
	
func _attach_conflict_to_stage():
	var conflict_node = conflict_node_scene.instance()
	var stage = G.node_current_stage_root
	stage.add_child(conflict_node)
	active_conflict_node = conflict_node
	return conflict_node
	
func _finish_conflict_state():
	active_conflict_node.queue_free()
	G.node_active_rebel.get_node('camera').current = true
	get_tree().paused = false
	active_conflict_node = null
