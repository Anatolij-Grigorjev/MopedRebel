extends Node2D

var Logger = preload("res://globals/logger.gd")
var LOG
var InfoPopup = preload("res://common/shout_popup.tscn")

var conflict_rebel_node = null
var conflict_with_node = null
var active_conflict_screen_node = null

func _ready():
	LOG = Logger.new('VS')
	_reset_conflict_nodes()
	S.connect_signal_to(
		S.SIGNAL_REBEL_START_CONFLICT, 
		self, 
		"_init_rebel_other_conflict_screen"
	)
	S.connect_signal_to(
		S.SIGNAL_CONFLICT_CHOSE_RESOLUTION,
		self,
		"_init_info_popup"
	)
	S.connect_signal_to(
		S.SIGNAL_INFO_POPUP_CLOSED,
		self,
		"_init_finish_conflict_state"
	)
	LOG.info("Loaded gloal conflict tracker node VS!")

func _init_rebel_other_conflict_screen(enemy_node, bribe_money, diss_min_sc, fight_toughness):
	conflict_rebel_node = G.node_active_rebel
	conflict_with_node = enemy_node
	var conflict_root = _attach_conflict_to_stage()
	var conflict_options_node = conflict_root.get_node('outer_container/selection_bgcolor/selection_bg/selection_options')
	var enemy_texture = enemy_node.sprite.texture
	conflict_options_node.init_conflict_with_details(enemy_texture, bribe_money, diss_min_sc, fight_toughness)
	#prepare conflict camera
	var conflict_camera = conflict_root.get_node('camera')
	conflict_root.rect_size = get_viewport_rect().size
	conflict_camera.current = true
	conflict_camera.align()
	get_tree().paused = true
	
func _attach_conflict_to_stage():
	var conflict_node = ConflictRoot.instance()
	var stage = G.node_current_stage_root
	stage.add_child(conflict_node)
	active_conflict_screen_node = conflict_node
	return conflict_node

func _init_info_popup(conflict_type, info_text):
	var new_info_dialog = InfoPopup.instance()
	G.node_current_stage_root.add_child(new_info_dialog)
	new_info_dialog.show_popup(info_text)
	
func _init_finish_conflict_state():
	F.invoke_later(
		self,
		"_finish_conflict_state",
		0.4
	)

func _finish_conflict_state():
	if (conflict_with_node != null and conflict_with_node.has_method("_post_conflict")):
		LOG.info("invoking post-conflict handler for node %s", [conflict_with_node])
		conflict_with_node._post_conflict()
	active_conflict_screen_node.queue_free()
	G.node_active_rebel.get_node('camera').current = true
	get_tree().paused = false
	_reset_conflict_nodes()
	
func _reset_conflict_nodes():
	active_conflict_screen_node = null
	conflict_rebel_node = null
	conflict_with_node = null
