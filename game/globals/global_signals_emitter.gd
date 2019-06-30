extends Node

var Logger = preload("res://globals/logger.gd")
var LOG

const DEBUG_SIGNALS = true

signal mounting_moped
signal moped_jump_curb
signal rebel_position_changed(new_position, new_rebel_state)
signal entity_offscreen_for_time(node, time)
signal enemy_dissed(enemy_node)
signal enemy_scared(enemy_node)

const SIGNAL_REBEL_MOUNT_MOPED = "mounting_moped"
const SIGNAL_REBEL_JUMP_CURB_ON_MOPED = "moped_jump_curb"
const SIGNAL_REBEL_CHANGED_POSITION = "rebel_position_changed"
const SIGNAL_ENEMY_DISSED = "enemy_dissed"
const SIGNAL_ENEMY_SCARED = "enemy_scared"

const known_singals = [
	SIGNAL_REBEL_MOUNT_MOPED,
	SIGNAL_REBEL_JUMP_CURB_ON_MOPED,
	SIGNAL_REBEL_CHANGED_POSITION,
	SIGNAL_ENEMY_DISSED,
	SIGNAL_ENEMY_SCARED
]


func _ready():
	LOG = Logger.new('S')
	LOG.info("Loaded global signals emitter node S!")
	pass


func _assert_known_signal(signal_name):
	if (signal_name in known_singals):
		pass
	else:
		LOG.error("No signal name found for constant %s!", signal_name)
		


func connect_signal_to(signal_name, target, method, binds = [], flags = 0):
	_assert_known_signal(signal_name)
	if (target == null or method == null):
		LOG.error("Bad target object or method, check invocation!")
	
	if DEBUG_SIGNALS:
		LOG.info("connecting %s to %s#%s with %s binds", [signal_name, target, method, binds.size()])
	
	connect(signal_name, target, method, binds, flags)
		


func emit_signal0(signal_name):
	_emit_signal_variadic(signal_name)

func emit_signal1(signal_name, arg1):
	_emit_signal_variadic(signal_name, [arg1])

func emit_signal2(signal_name, arg1, arg2):
	_emit_signal_variadic(signal_name, [arg1, arg2])
	
func emit_signal3(signal_name, arg1, arg2, arg3):
	_emit_signal_variadic(signal_name, [arg1, arg2, arg3])

func emit_signal4(signal_name, arg1, arg2, arg3, arg4):
	_emit_signal_variadic(signal_name, [arg1, arg2, arg3, arg4])

func _emit_signal_variadic(signal_name, args_list = []):
	_assert_known_signal(signal_name)
	if (args_list == null):
		LOG.warn("passed null args_list! Using empty list...") 
		args_list = []
		
	if DEBUG_SIGNALS:
		LOG.info("signal %s with %s args: %s", [signal_name, args_list.size(), args_list])
	match args_list.size():
		0:
			emit_signal(signal_name)
		1:
			emit_signal(signal_name, args_list[0])
		2:
			emit_signal(signal_name, args_list[0], args_list[1])
		3:
			emit_signal(signal_name, args_list[0], args_list[1], args_list[2])
		4:
			emit_signal(signal_name, args_list[0], args_list[1], args_list[2], args_list[3])
		#if quantity more than largest qualifier above, just pass all array as a single value
		_:
			emit_signal(signal_name, args_list)
			
	
	
