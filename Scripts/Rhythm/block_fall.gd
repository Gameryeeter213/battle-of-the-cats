extends Node2D

var note_time :float = 0.0
var lane :int = 0
var hit_y = 334.0
var spawn_y = -100.0
var travel_time = 2.0 # seconds
var speed = (hit_y - spawn_y) / travel_time
var hold_time :float = 0.0
@onready var head := $Bottom
@onready var body := $Middle
@onready var tail := $Top
@onready var single := $Block
@onready var missSFX :=$"../../Miss"
@onready var Music :AudioStreamPlayer2D = $"../../Music"


func _ready() -> void:
	if hold_time == 0.0:
		single.show()
		head.hide()
		tail.hide()
		body.hide()
		single.play("Lane "+str(lane))
	elif hold_time >0.0:
		var body_height :float = hold_time * speed
		head.position.y = 0
		body.position.y = 0
		body.scale.y = body_height
		tail.position.y = -body_height
		head.play("Lane "+str(lane))
		body.play("Lane "+str(lane))
		tail.play("Lane "+str(lane))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y = (hit_y + (Rhythm.song_time - note_time) * speed)
	var time_diff = (note_time+hold_time-Rhythm.song_time)*1000
	if time_diff <= -140:
		Music.volume_linear = 0.0
		missSFX.pitch_scale = randf_range(0.9,1.1)
		missSFX.play()
		Rhythm.lane_queue[lane].pop_front()
		Rhythm.miss +=1
		Rhythm.miss_shake = 1
		Rhythm.combo = 0
		queue_free()
