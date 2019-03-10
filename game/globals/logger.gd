
var owner_node

var current_log_levels = C.LOG_LEVELS.keys()

var entity_name
var entity_type_descriptor

func _init(owner_node):
	F.assert_not_null(owner_node)
	#logger for nodes only!
	F.assert_is_true(
		owner_node is Node, 
		"supplied owner for logger %s was not a Node!" % owner_node
	)
	self.owner_node = owner_node
	entity_name = owner_node.name
	entity_type_descriptor = owner_node

func debug(format, args = []):
	_log_at_level(C.LOG_LEVELS.DEBUG, format, args)

func info (format, args = []):
	_log_at_level(C.LOG_LEVELS.INFO, format, args)
	
func warn(format, args = []):
	_log_at_level(C.LOG_LEVELS.WARN, format, args)

func error(format, args = [], break_execution = true):
	_log_at_level(C.LOG_LEVELS.ERROR, format, args, break_execution)

func _log_at_level(level, format, message_args = [], break_execution_if_error = true):
	if (level < C.CURRENT_LOG_LEVEL):
		return
	var full_prefix = "%s -- %s%s: " % [current_log_levels[level], entity_name, entity_type_descriptor]
	var full_format = full_prefix + format
	if (break_execution_if_error and level == C.LOG_LEVELS.ERROR):
		F.log_error(full_format, message_args)
	else:
		F.logf(full_format, message_args)

