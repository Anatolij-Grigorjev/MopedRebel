extends Node

var Logger = preload("res://globals/logger.gd")
var LOG

signal mounting_moped
signal unmounting_moped
signal rebel_cause_conflict(enemy_node, bribe_money, min_req_sc, enemy_toughness)
signal rebel_moped_collided
signal conflict_resolved
signal conflict_chose_resolution(choice_type, choice_param)
signal conflict_info_popup_close
signal rebel_gain_sc(added_sc_amount)
signal moped_jump_curb
signal rebel_leaving_chunk(chunk_idx, facing)
signal rebel_entering_chunk(chunk_idx, facing)
signal rebel_position_changed(new_position, new_rebel_state)
signal rebel_exited_stage(facing)

const SIGNAL_REBEL_MOUNT_MOPED = "mounting_moped"
const SIGNAL_REBEL_UNMOUNT_MOPED = "unmounting_moped"
const SIGNAL_REBEL_START_CONFLICT = "rebel_cause_conflict"
const SIGNAL_REBEL_MOPED_COLLISION = "rebel_moped_collided"
const SIGNAL_CONFLICT_RESOLVED = "conflict_resolved"
const SIGNAL_CONFLICT_CHOSE_RESOLUTION = "conflict_chose_resolution"
const SIGNAL_INFO_POPUP_CLOSED = "conflict_info_popup_close"
const SIGNAL_REBEL_GAIN_SC = "rebel_gain_sc"
const SIGNAL_REBEL_JUMP_CURB_ON_MOPED = "moped_jump_curb"
const SIGNAL_REBEL_LEAVING_CHUNK = "rebel_leaving_chunk"
const SIGNAL_REBEL_ENTERING_CHUNK = "rebel_entering_chunk"
const SIGNAL_REBEL_CHANGED_POSITION = "rebel_position_changed"
const SIGNAL_REBEL_EXITED_STAGE = "rebel_exited_stage"

const known_singals = [
	SIGNAL_REBEL_MOUNT_MOPED,
	SIGNAL_REBEL_UNMOUNT_MOPED,
	SIGNAL_REBEL_START_CONFLICT,
	SIGNAL_REBEL_MOPED_COLLISION,
	SIGNAL_CONFLICT_RESOLVED,
	SIGNAL_CONFLICT_CHOSE_RESOLUTION,
	SIGNAL_INFO_POPUP_CLOSED,
	SIGNAL_REBEL_GAIN_SC,
	SIGNAL_REBEL_JUMP_CURB_ON_MOPED,
	SIGNAL_REBEL_LEAVING_CHUNK,
	SIGNAL_REBEL_ENTERING_CHUNK,
	SIGNAL_REBEL_CHANGED_POSITION,
	SIGNAL_REBEL_EXITED_STAGE
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
			
	
	
