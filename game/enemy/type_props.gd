extends Node2D

var Logger = preload("res://globals/logger.gd")
var LoadedTypeProps = preload("res://enemy/enemy_props.gd")
var LOG

export (String) var type_id
export (Resource) var props
export (float) var props_rand_prc = 0.1

export (float) var fear_sc = 0
export (float) var escape_delay_sec = 0
export (PoolStringArray) var disses = []


func _ready():
	F.assert_not_null(type_id)
	props = LoadedTypeProps.new(type_id)
	LOG = Logger.new("%s-props" % F.get_node_name_safe(self.owner))
	LOG.info(props.as_string())

	fear_sc = _randomize_prop_val(props.fear_sc)
	escape_delay_sec = _randomize_prop_val(props.escape_delay_sec)
	disses = props.disses

	LOG.info(as_string())


func _randomize_prop_val(base_val):
	return rand_range(
		base_val * (1 - props_rand_prc),
		base_val * (1 + props_rand_prc)
	)

func as_string():
	return """READY PROPS:
	Enemy type id: %s
	fear SC: %s,
	escape delay (sec): %s
	num disses: %s
	""" % [type_id, fear_sc, escape_delay_sec, disses.size()]