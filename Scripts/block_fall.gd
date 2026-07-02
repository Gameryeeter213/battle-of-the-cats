extends Node2D

var note_time :float = 0.0
var lane :int = 0
var hit_y = 334.0
var spawn_y = -100.0
var travel_time = 2.0 # seconds
var speed = (hit_y - spawn_y) / travel_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y = (hit_y + (Global.song_time - note_time) * speed)
	if position.y >= 400:
		queue_free()
