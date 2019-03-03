
var owner_node

var current_log_levels = C.LOG_LEVELS.keys()

func _init(owner_node):
	F.assert_not_null(owner_node)
	#logger for nodes only!
	F.assert_is_true(
		owner_node is Node, 
		"supplied owner for logger %s was not a Node!" % owner_node
	)
	self.owner_node = owner_node

func debug(format, args = []):
	_log_at_level(C.LOG_LEVELS.DEBUG, format, args)

func info (format, args = []):
	_log_at_level(C.LOG_LEVELS.INFO, format, args)
	
func warn(format, args = []):
	_log_at_level(C.LOG_LEVELS.WARN, format, args)

func _log_at_level(level, format, message_args = []):
	if (level < C.CURRENT_LOG_LEVEL):
		return
	var full_prefix = "%s %s %s: " % [owner_node, owner_node.name, current_log_levels[level]]
	var full_format = full_prefix + format
	F.logf(full_format, message_args)
