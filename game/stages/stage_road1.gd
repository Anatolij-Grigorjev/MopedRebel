extends Node2D

var rebel_on_foot_node
var rebel_on_moped_node

func _ready():
	rebel_on_foot_node = $rebel_on_foot
	rebel_on_moped_node = $rebel_on_moped
	init_rebel_on_foot()
	
	
func init_rebel_on_foot():
	rebel_on_moped_node.visible = false
	rebel_on_foot_node.get_node('camera').current = true
	
