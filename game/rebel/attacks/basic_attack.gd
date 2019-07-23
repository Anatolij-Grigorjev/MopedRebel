extends Area2D

signal hit_enemy(attack_node, enemy_node)

func _ready():
	pass

func _on_hit_body(body):
	#apply hit to enemy
	if (body.is_in_group(C.GROUP_ENEMY)):
		emit_signal("hit_enemy", self, body)
	pass
