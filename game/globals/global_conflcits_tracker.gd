extends Node2D

var conflict_node
var conflict_options_node

var conflict_rebel = null
var conflict_other = null

func _ready():
	conflict_node = preload("res://conflict/conflict_root.tscn").instance()
	add_child(conflict_node)
	conflict_node = $conflict_root
	conflict_options_node = conflict_node.get_node('outer_container/selection_bgcolor/selection_bg/selection_options')
	conflict_node.hide()
	conflict_options_node.set_physics_process(false)
	S.connect_signal_to(
		S.SIGNAL_REBEL_START_CONFLICT, 
		self, 
		"_prepare_rebel_conflict"
	)
	S.connect_signal_to(
		S.SIGNAL_TRANSPORT_START_CONFLICT,
		self, 
		"_prepare_other_conflict"
	)
	

func _prepare_rebel_conflict():
	conflict_rebel = G.node_active_rebel
	_check_start_conflict_screen()
	
func _prepare_other_conflict(other_node):
	conflict_other = other_node
	_check_start_conflict_screen()
	

func _check_start_conflict_screen():
	if (conflict_rebel != null and conflict_other != null):
		_init_rebel_other_conflict_screen(
			conflict_other.bribe_money,
			conflict_other.required_sc,
			conflict_other.driver_toughness
		)

func _init_rebel_other_conflict_screen(bribe_money, diss_min_sc, fight_toughness):
	conflict_options_node.init_conflict_with_details(bribe_money, diss_min_sc, fight_toughness)
	conflict_options_node.set_physics_process(true)
	conflict_node.show()
	#prepare conflict camera
	$conflict_root/camera.current = true
	$conflict_root.rect_size = get_viewport_rect().size
	get_tree().paused = true
