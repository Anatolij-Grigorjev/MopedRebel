extends Node

signal mounting_moped
signal unmounting_moped
signal rebel_cause_conflict(bribe_money, min_req_sc, enemy_toughness)
signal rebel_moped_collided
signal conflict_resolved

const SIGNAL_REBEL_MOUNT_MOPED = "mounting_moped"
const SIGNAL_REBEL_UNMOUNT_MOPED = "unmounting_moped"
const SIGNAL_REBEL_START_CONFLICT = "rebel_cause_conflict"
const SIGNAL_REBEL_MOPED_COLLISION = "rebel_moped_collided"
const SIGNAL_CONFLICT_RESOLVED = "conflict_resolved"

const known_singals = [
	SIGNAL_REBEL_MOUNT_MOPED,
	SIGNAL_REBEL_UNMOUNT_MOPED,
	SIGNAL_REBEL_START_CONFLICT,
	SIGNAL_REBEL_MOPED_COLLISION,
	SIGNAL_CONFLICT_RESOLVED
]


func _ready():
	print("Loaded global signals emitter node S!")
	pass


func _assert_known_signal(signal_name):
	if (signal_name in known_singals):
		pass
	else:
		F.log_error("No signal name found for constant %s!", signal_name)
		


func connect_signal_to(signal_name, target, method, binds = [], flags = 0):
	_assert_known_signal(signal_name)
	if (target == null or method == null):
		F.log_error("Bad target object or method, check invocation!")
	
	connect(signal_name, target, method, binds, flags)
		


func emit_signal0(signal_name):
	_emit_signal_variadic(signal_name)

func emit_signal1(signal_name, arg1):
	_emit_signal_variadic(signal_name, [arg1])

func emit_signal2(signal_name, arg1, arg2):
	_emit_signal_variadic(signal_name, [arg1, arg2])
	
func emit_signal3(signal_name, arg1, arg2, arg3):
	_emit_signal_variadic(signal_name, [arg1, arg2, arg3])

func _emit_signal_variadic(signal_name, args_list = []):
	_assert_known_signal(signal_name)
	if (args_list == null):
		F.logf("WARN: passed null args_list! Using empty list...") 
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
		#if quantity more than largest qualifier above, just pass all array as a single value
		_:
			emit_signal(signal_name, args_list)
			
	
	
