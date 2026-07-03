extends Node

var song_time :float = 0.0
var score :int = 0
var miss :int = 0
var goods :int = 0
var perfects :int = 0
var combo :int = 0
var combo_mult :int = 1
var best_combo :int = 0
var miss_shake :float = 0.0
var active_hold = {
	0: null,
	1: null,
	2: null,
	3: null,
	4: null
}
var lane_queue := {
	0: [],
	1: [],
	2: [],
	3: [],
	4: []
}

func update_mult():
	if combo >=10 and combo<25:
		combo_mult = 2
	elif combo >=25 and combo<50:
		combo_mult = 3
	elif combo >=50:
		combo_mult = 4
	else:
		combo_mult = 1

func reset():
	song_time = 0.0
	score = 0
	miss = 0
	goods = 0
	perfects = 0
	combo = 0
	combo_mult = 1
	best_combo = 0
	miss_shake = 0.0
	lane_queue = {
	0: [],
	1: [],
	2: [],
	3: [],
	4: []
	}
	active_hold = {
	0: null,
	1: null,
	2: null,
	3: null,
	4: null
	}
