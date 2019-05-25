extends Timer

export(NodePath) var node_origin_path
export(String) var node_receiver_action

var node_origin

func _ready():
	one_shot = false
	autostart = false
	node_origin = get_node(node_origin_path)
	connect('timeout', self, '_provide_new_rebel_direction')
	pass

func _provide_new_rebel_direction():
	if (node_origin == null or node_receiver_action == null):
		return
	var new_direction = F.get_speed_to_active_rebel_direction(node_origin)
	node_origin.call(node_receiver_action, new_direction)
