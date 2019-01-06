extends Node2D

var rebel_on_foot_scene = preload("res://rebel/rebel_on_foot.tscn")
var rebel_on_moped_scene = preload("res://rebel/rebel_on_moped.tscn")

var to_spawn
var spawn_pos

var spawn_pairs = []
var idx = 0

func _ready():
	spawn_pairs = [
	{
		"scene": rebel_on_foot_scene,
		"pos": $spwn_foot
	},
	{
		"scene": rebel_on_moped_scene,
		"pos": $spwn_moped
	}
	]
	idx = spawn_pairs.size() - 1
	next_spawn()
	
	pass
	
func next_spawn():
	idx = (idx + 1) % spawn_pairs.size()
	var next = spawn_pairs[idx]
	to_spawn = next.scene
	spawn_pos = next.pos

func _process(delta):
	
	if (Input.is_action_just_released("spawn_moped")):
		var instance = to_spawn.instance()
		instance.global_position = spawn_pos.global_position
		self.add_child(instance)
		next_spawn()
	
	pass
