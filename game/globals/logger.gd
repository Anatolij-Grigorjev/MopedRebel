
var owner_node

var current_log_levels = C.LOG_LEVELS.keys()

var entity_name
var entity_type_descriptor

func _init(owner_descriptor):
	F.assert_not_null(owner_descriptor)
	
	var descriptor_type = typeof(owner_descriptor)
	match(descriptor_type):
		TYPE_OBJECT:
			entity_name = '[%s:%s]' % [owner_descriptor.name, F.get_node_name_id(owner_descriptor)]
			entity_type_descriptor = ''
		TYPE_STRING:
			entity_name = '[%s]' % owner_descriptor
			entity_type_descriptor = ''
		_:
			error('Supported owner types for logger only Node and String, got %s!', [descriptor_type])

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

