extends Node

const NODE_NAME = 'VS'

var ConflictArena = preload("res://conflict/conflict_arena.tscn")
var RebelArenaEscape = preload("res://rebel/rebel_arena_escape.tscn")
var Logger = preload("res://globals/logger.gd")
var LOG

var rest_enemies_cache = []
var conflict_enemies = []
var current_arena

func _ready():
	LOG = Logger.new(NODE_NAME)
	LOG.info('Conflict tracker node %s loaded!' % NODE_NAME)
	pass
	
func rebel_started_conflict_with(enemy_node):
	if (not rest_enemies_cache.empty()):
		LOG.error(
			"Tried to start rebel conflict with %s while previous conflcit enemy cache holds %s enemies!",
			[enemy_node, rest_enemies_cache.size()]
		)
	
	var current_rebel = G.node_active_rebel
	conflict_enemies.append(enemy_node)
	#create arena instance
	var arena = ConflictArena.instance()
	#place at conflict position
	arena.global_position = current_rebel.global_position
	current_rebel.owner.add_child(arena)
	current_arena = arena
	#get rest stage enemies
	var rest_stage_enemies = get_tree().get_nodes_in_group(C.GROUP_ENEMY)
	rest_stage_enemies.erase(enemy_node)
	_cache_enemies(rest_stage_enemies)
	#attach arena escape node to rebel
	var rebel_arena_escape = RebelArenaEscape.instance()
	rebel_arena_escape.delivery_time_penalty = (
		enemy_node.get_node('type_props').escape_delay_sec)
	current_rebel.add_child(rebel_arena_escape)
	rebel_arena_escape.connect("rebel_escaped", current_rebel, "escaped_conflict")
	for wall in arena.get_children():
		rebel_arena_escape.connect("rebel_start_escape", wall, "_rebel_start_escape")
		rebel_arena_escape.connect("rebel_stop_escape", wall, "_rebel_stop_escape")
	
func _cache_enemies(enemies_list):
	#save data for re-insertion after conflict done
	for rest_enemy_node in enemies_list:
		var enemy_parent = rest_enemy_node.get_parent()
		rest_enemies_cache.append({
			'node': rest_enemy_node,
			'parent': enemy_parent,
			'global_position': rest_enemy_node.global_position
		})
		enemy_parent.remove_child(rest_enemy_node)
		
func end_active_conflict():
	if (not current_arena):
		LOG.error("Tried to end conflict but no current_arena was set!")
	current_arena.queue_free()
	current_arena = null
	_restore_cached_enemies()
	G.node_active_rebel.end_conflict()
	
func _restore_cached_enemies():
	for cached_node_info in rest_enemies_cache:
		var node = cached_node_info['node']
		var parent = cached_node_info['parent']
		var cached_position = cached_node_info['global_position']
		parent.add_child(node)
		node.global_position = cached_position
	rest_enemies_cache.clear()
	
func connect_rebel_attacks_to(enemy_node, receiver_name):
	var current_rebel = G.node_active_rebel
	#connect on foot rebel attacks
	if (current_rebel == G.node_rebel_on_foot):
		var attacks_node = current_rebel.get_node('attack_bodies')
		for attack_node in attacks_node.get_children():
			attack_node.connect("hit_enemy", enemy_node, receiver_name)
			
func remove_enemy_from_conflict(enemy_node):
	conflict_enemies.erase(enemy_node)
	if (conflict_enemies.empty()):
		end_active_conflict()
	
	
