extends Position2D

var ShoutPopup = preload("res://common/shout_popup.tscn")

var Logger = preload("res://globals/logger.gd")
var LOG

const SHOUT_BASE_LENGTH_SEC = 1.2
const SHOUT_SHOW_PER_LETTER = 0.02

func _ready():
	LOG = F.configure_sub_logger(Logger.new(""), owner, "shout")
	pass

func _shout_at_enemy(enemy_node):
	#ensure correct rebel is shouting
	if (owner != G.node_active_rebel or enemy_node.is_scared):
		return 
	else:
		var props = enemy_node.get_node('type_props')
		var random_diss = F.get_rand_array_elem(props.disses)
		var shout_time = get_line_shout_time(random_diss)
		shout_for_seconds(random_diss, shout_time)

func get_line_shout_time(line = ""):
	return SHOUT_BASE_LENGTH_SEC + (line.length() * SHOUT_SHOW_PER_LETTER)

func shout_for_seconds(shout_line, for_seconds = get_line_shout_time(shout_line)):
	LOG.info("rebel shouting %s at %s for %s seconds", 
		[shout_line, global_position, for_seconds])
	var shout_dialog = ShoutPopup.instance()
	shout_dialog.shout_line = shout_line
	shout_dialog.visible_time = for_seconds
	add_child(shout_dialog)
	shout_dialog.rect_position = global_position
	shout_dialog.show_popup()