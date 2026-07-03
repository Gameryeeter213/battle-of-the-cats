extends Node2D

var note_time :float = 0.0
var lane :int = 0
var hit_y = 334.0
var spawn_y = -100.0
var travel_time = 2.0 # seconds
var speed = (hit_y - spawn_y) / travel_time
var hold_time :float = 0.0
@onready var head := $Sprite2D
@onready var body := $TextureRect
@onready var tail := $TextureRect2

func _ready() -> void:
	if hold_time >0.0:
		var body_height :float = hold_time * speed
		head.position.y = 0
		body.position.y = -body_height / 2
		body.scale.y = body_height
		tail.position.y = -body_height
	else:
		body.hide()
		tail.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y = (hit_y + (Global.song_time - note_time) * speed)
	var time_diff = (note_time+hold_time-Global.song_time)*1000
	if time_diff <= -140:
		Global.lane_queue[lane].pop_front()
		Global.miss +=1
		Global.miss_shake = 1
		Global.combo = 0
		queue_free()
