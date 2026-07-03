extends Node2D

#Create variables
@onready var block :PackedScene = preload("res://Scenes/block.tscn")
@onready var audioplayer :AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var lane_0 :Label = $"CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/VBoxContainer/Container/HBoxContainer2/Lane 0"
@onready var lane_1 :Label = $"CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/VBoxContainer/Container/HBoxContainer2/Lane 1"
@onready var lane_2 :Label = $"CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/VBoxContainer/Container/HBoxContainer2/Lane 2"
@onready var lane_3 :Label = $"CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/VBoxContainer/Container/HBoxContainer2/Lane 3"
@onready var lane_4 :Label = $"CanvasLayer/MarginContainer/PanelContainer/VBoxContainer/VBoxContainer/Container/HBoxContainer2/Lane 4"
@onready var score_board :Label = $CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Score
@onready var camera :Camera2D = $Camera2D
@onready var lane_0Part :GPUParticles2D = $"Lane 0 Particles"
@onready var lane_1Part :GPUParticles2D = $"Lane 1 Particles"
@onready var lane_2Part :GPUParticles2D = $"Lane 2 Particles"
@onready var lane_3Part :GPUParticles2D = $"Lane 3 Particles"
@onready var lane_4Part :GPUParticles2D = $"Lane 4 Particles"
@onready var BlockLayer :CanvasLayer = $BlockLayer
@export var shake_scale :float = 1.0

enum State {
	Waiting,
	Playing
}
var state = State.Waiting
var bpm: float = 120.0
var instrument := ""
var charts := {}
var beat :float = 0.0
var seconds :float = beat * 60.0 / bpm
var index :int = 0
var note_time :float = 0.0
var notes := []
var time_begin :float
var time_delay :float 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.reset()
	$AnimatedSprite2D.play()
	$AnimatedSprite2D2.play()
	load_song("res://Assets/Tracks/Crazy Train.JSON")
	instrument = "Guitar"
	notes = charts[instrument]
	print(notes)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.Waiting:
			return
		State.Playing:
			play_chart()
			check_held_notes()
			Global.miss_shake = lerp(Global.miss_shake, 0.0, 2*delta)
			camera.offset.x += randf_range(-15*shake_scale*Global.miss_shake,15*shake_scale*Global.miss_shake)
			if Global.song_time>25.0:
				get_tree().change_scene_to_file("res://Scenes/end_rythm.tscn")
			score_board.text = str(int(lerp(int(score_board.text), Global.score, 6*delta)))
			

func load_song(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	
	#Error is file not found
	if file == null:
		push_error("Couldn't open chart!")
		return
	
	#Go throught the file line by line
	while !file.eof_reached():
		var line = file.get_line().strip_edges()
	
		# Skip blank lines
		if line == "":
			continue
	
		# BPM
		if line.begins_with("BPM:"):
			bpm = line.trim_prefix("BPM:").to_float()
			continue
	
		# Section header
		if line.begins_with("[") and line.ends_with("]"):
			instrument = line.substr(1, line.length() - 2)
			charts[instrument] = []
			continue
		var parts = line.split(",")
		if parts.size() == 3:
			var beat = parts[0].to_float()
			var lane = parts[1].to_int()
			var duration = parts[2].to_float()
			charts[instrument].append({
				"beat": beat,
				"lane": lane,
				"duration": duration
			})
	file.close()

func start_chart():
	time_begin = Time.get_ticks_usec()
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	audioplayer.play()

func play_chart():
	Global.song_time = (Time.get_ticks_usec() - time_begin)/ 1000000.0
	Global.song_time -= time_delay
	Global.song_time = max(0, Global.song_time)
	while index < notes.size():
		var note = notes[index]
		note_time = note.beat * 60.0 / bpm
		var hold_time :float = note.duration * 60.0 / bpm
		if Global.song_time+2.0 >= note_time:
			spawn_note(note.lane, note_time, hold_time)
			index += 1
		else:
			break

func spawn_note(lane: int, note_time: float, hold_time :float):
	var Block := block.instantiate()
	Block.note_time = note_time
	Block.hold_time = hold_time
	Block.position = Vector2(float(144+(88*lane)),float(-100))
	Block.name = "lane_%d_time_%.3f" % [lane, note_time]
	Block.lane = lane
	Global.lane_queue[lane].append({
		"note_time": note_time,
		"node": Block,
		"duration": hold_time
		})
	BlockLayer.add_child(Block)

func _unhandled_input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("ui_accept") and state == State.Waiting:
		$AnimationPlayer.play("Reveal area")
		start_chart()
		state = State.Playing
	
	if Input.is_action_just_pressed("Lane 0"):
		handle_lane(0, lane_0, lane_0Part,"Lane 0")
	
	elif Input.is_action_just_pressed("Lane 1"):
		handle_lane(1, lane_1, lane_1Part,"Lane 1")
	
	elif Input.is_action_just_pressed("Lane 2"):
		handle_lane(2, lane_2, lane_2Part,"Lane 2")
	
	elif Input.is_action_just_pressed("Lane 3"):
		handle_lane(3, lane_3, lane_3Part,"Lane 3")
	
	elif Input.is_action_just_pressed("Lane 4"):
		handle_lane(4, lane_4, lane_4Part,"Lane 4")

func handle_lane(lane: int, lane_label:Label, lane_part :GPUParticles2D, laneName :String):
	if Global.lane_queue[lane].is_empty():
		return
	var entry = Global.lane_queue[lane][0]
	if not is_instance_valid(entry["node"]):
		Global.lane_queue[lane].pop_front()
		return
	var note_node :Node2D = entry["node"]
	var note_time_check :float = entry["note_time"]
	var time_diff :float = abs((note_time_check-Global.song_time)*1000)
	var duration :float = entry["duration"]
	if time_diff >=140:
		return
	if time_diff > 75 and time_diff <140:
		Global.miss +=1
		Global.miss_shake = 1.0
		Global.combo =0
		lane_label.text = "MISS"
		Global.lane_queue[lane].pop_front()
		note_node.queue_free()
		Global.update_mult()

	elif time_diff > 20:
		Global.goods +=1
		Global.combo+=1
		Global.score += 50*Global.combo_mult
		lane_label.text = "GOOD"
		lane_part.emitting = true
		if duration > 0.0:
			Global.active_hold[lane] = entry
			return
	elif time_diff <= 20:
		Global.perfects +=1
		Global.combo+=1
		Global.score += 100*Global.combo_mult
		lane_label.text = "PERFECT"
		lane_part.emitting = true
		if duration > 0.0:
			Global.active_hold[lane] = entry
			return
	if not duration > 0.0:
		Global.lane_queue[lane].pop_front()
		note_node.queue_free()
		Global.update_mult()

func check_held_notes():
	for lane in range(5):
		var hold = Global.active_hold[lane]
		if hold == null:
			continue
		if !Input.is_action_pressed("Lane %d" % lane):
			fail_hold(lane)
			continue
		if Global.song_time >= hold["note_time"] + hold["duration"]:
			complete_hold(lane)

func fail_hold(lane :int):	
	var note_node :Node2D =  Global.active_hold[lane]["node"]
	Global.lane_queue[lane].pop_front()
	Global.miss +=1
	Global.miss_shake = 1.0
	Global.combo =0
	note_node.queue_free()
	Global.update_mult()
	Global.active_hold[lane] = null

func complete_hold(lane :int):
	var note_node :Node2D =  Global.active_hold[lane]["node"]
	var NoteTime :float =  Global.active_hold[lane]["note_time"]
	var Duration :float =  Global.active_hold[lane]["duration"]
	var time_diff :float = abs(NoteTime+Duration-Global.song_time)*1000.0
	if time_diff > 20 and !Input.is_action_pressed("Lane "+str(lane)):
		print("GOOD")
		Global.goods +=1
		Global.combo+=1
		Global.score += 50*Global.combo_mult
		Global.lane_queue[lane].pop_front()
		note_node.queue_free()
		Global.update_mult()
		Global.active_hold[lane] = null
	elif time_diff <= 20 and !Input.is_action_pressed("Lane "+str(lane)):
		print("PERFECT")
		Global.perfects +=1
		Global.combo+=1
		Global.score += 100*Global.combo_mult
		Global.lane_queue[lane].pop_front()
		note_node.queue_free()
		Global.update_mult()
		Global.active_hold[lane] = null
	elif time_diff >=140:
		print("MISS")
		Global.lane_queue[lane].pop_front()
		note_node.queue_free()
		Global.update_mult()
		Global.active_hold[lane] = null
