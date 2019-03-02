extends Timer

var node_origin
var node_receiver_action

func _ready():
	one_shot = false
	connect('timeout', self, '_provide_new_rebel_direction')
	pass

func _provide_new_rebel_direction():
	if (node_origin == null or node_receiver_action):
		return
	
	var new_direction = F.get_speed_to_active_rebel_direction(node_origin)
	node_origin.call(node_receiver_action, new_direction)
