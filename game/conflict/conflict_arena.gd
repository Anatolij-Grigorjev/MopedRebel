extends Node2D

export(Vector2) var arena_size = Vector2(1200, 600)

func _ready():
	
	var arena_extents = arena_size / 2
	$conflict_arena_wall_left.position.x = -arena_extents.x
	$conflict_arena_wall_right.position.x = arena_extents.x
	
	var stage_size = G.node_current_stage_root.stage_size
	
	#clamp arena to stage start
	if ($conflict_arena_wall_left.global_position.x < 0):
		global_position.x -= $conflict_arena_wall_left.global_position.x
	#clamp arena to stage end
	if ($conflict_arena_wall_right.global_position.x > stage_size.x):
		global_position.x -= $conflict_arena_wall_right.global_position.x - stage_size.x
	
