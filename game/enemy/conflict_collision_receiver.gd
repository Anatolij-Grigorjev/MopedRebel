extends Node2D

var collided = false

var bribe_money
var min_diss_sc
var enemy_toughness

func _ready():
	pass

func set_conflict_params(bribe_money, min_diss_sc, enemy_toughness):
	self.bribe_money = bribe_money 
	self.min_diss_sc = min_diss_sc
	self.enemy_toughness = enemy_toughness

func react_collision(collision):
	if (not collided):
		S.emit_signal(S.SIGNAL_REBEL_START_CONFLICT,
			owner,
			bribe_money,
			min_diss_sc,
			enemy_toughness
		)