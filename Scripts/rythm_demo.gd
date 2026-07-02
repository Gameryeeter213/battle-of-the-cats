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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	play_chart()
	if Global.song_time>23.0:
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
		if parts.size() == 2:
			var beat = parts[0].to_float()
			var lane = parts[1].to_int()
			charts[instrument].append({
				"beat": beat,
				"lane": lane
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
		note_time = note.beat * 60.0 	/ bpm
		if Global.song_time+2.0 >= note_time:
			spawn_note(note.lane, note_time)
			index += 1
		else:
			break

func spawn_note(lane: int, note_time: float):
	var Block := block.instantiate()
	Block.note_time = note_time
	Block.position = Vector2(float(144+(88*lane)),float(-100))
	Block.name = "lane_%d_time_%.3f" % [lane, note_time]
	Block.lane = lane
	Global.lane_queue[lane].append({
		"note_time": note_time,
		"node": Block
		})
	add_child(Block)

func _unhandled_input(event: InputEvent) -> void:
	
	if Input.is_action_just_pressed("ui_accept"):
		$CanvasLayer/PanelContainer.hide()
		start_chart()
	
	if Input.is_action_just_pressed("Lane 0"):
		if Global.lane_queue[0].is_empty():
			return
		var entry = Global.lane_queue[0][0]
		if not is_instance_valid(entry["node"]):
			Global.lane_queue[0].pop_front()
			return
		var note_node :Node2D = entry["node"]
		var note_time_check :float = entry["note_time"]
		var time_diff = abs((note_time_check-Global.song_time)*1000)
		if time_diff >=140:
			return
		if time_diff > 75 and time_diff <140:
			Global.miss +=1
			Global.combo =0
			lane_0.text = "MISS"
		elif time_diff > 20:
			Global.goods +=1
			Global.combo+=1
			Global.score += 50*Global.combo_mult
			lane_0.text = "GOOD"
		elif time_diff <= 20:
			Global.perfects +=1
			Global.combo+=1
			Global.score += 100*Global.combo_mult
			lane_0.text = "PERFECT"
		Global.lane_queue[0].pop_front()
		note_node.queue_free()
		Global.update_mult()
	
	elif Input.is_action_just_pressed("Lane 1"):
		if Global.lane_queue[1].is_empty():
			return
		var entry = Global.lane_queue[1][0]
		if not is_instance_valid(entry["node"]):
			Global.lane_queue[1].pop_front()
			return
		var note_node :Node2D = entry["node"]
		var note_time_check :float = entry["note_time"]
		var time_diff = abs((note_time_check-Global.song_time)*1000)
		if time_diff >=140:
			return
		if time_diff > 75 and time_diff <140:
			Global.miss +=1
			Global.combo =0
			lane_1.text = "MISS"
		elif time_diff > 20:
			Global.goods +=1
			Global.combo+=1
			Global.score += 50*Global.combo_mult
			lane_1.text = "GOOD"
		elif time_diff <= 20:
			Global.perfects +=1
			Global.combo+=1
			Global.score += 100*Global.combo_mult
			lane_1.text = "PERFECT"
		Global.lane_queue[1].pop_front()
		note_node.queue_free()
		Global.update_mult()
	
	elif Input.is_action_just_pressed("Lane 2"):
		if Global.lane_queue[2].is_empty():
			return
		var entry = Global.lane_queue[2][0]
		if not is_instance_valid(entry["node"]):
			Global.lane_queue[2].pop_front()
			return
		var note_node :Node2D = entry["node"]
		var note_time_check :float = entry["note_time"]
		var time_diff = abs((note_time_check-Global.song_time)*1000)
		if time_diff >=140:
			return
		if time_diff > 75 and time_diff <140:
			Global.miss +=1
			Global.combo =0
			lane_2.text = "MISS"
		elif time_diff > 20:
			Global.goods +=1
			Global.combo+=1
			Global.score += 50*Global.combo_mult
			lane_2.text = "GOOD"
		elif time_diff <= 20:
			Global.perfects +=1
			Global.combo+=1
			Global.score += 100*Global.combo_mult
			lane_2.text = "PERFECT"
		Global.lane_queue[2].pop_front()
		note_node.queue_free()
		Global.update_mult()
	
	elif Input.is_action_just_pressed("Lane 3"):
		if Global.lane_queue[3].is_empty():
			return
		var entry = Global.lane_queue[3][0]
		if not is_instance_valid(entry["node"]):
			Global.lane_queue[3].pop_front()
			return
		var note_node :Node2D = entry["node"]
		var note_time_check :float = entry["note_time"]
		var time_diff = abs((note_time_check-Global.song_time)*1000)
		if time_diff >=140:
			return
		if time_diff > 75 and time_diff <140:
			Global.miss +=1
			Global.combo =0
			lane_3.text = "MISS"
		elif time_diff > 20:
			Global.goods +=1
			Global.combo+=1
			Global.score += 50*Global.combo_mult
			lane_3.text = "GOOD"
		elif time_diff <= 20:
			Global.perfects +=1
			Global.combo+=1
			Global.score += 100*Global.combo_mult
			lane_3.text = "PERFECT"
		Global.lane_queue[3].pop_front()
		note_node.queue_free()
		Global.update_mult()
	
	elif Input.is_action_just_pressed("Lane 4"):
		if Global.lane_queue[4].is_empty():
			return
		var entry = Global.lane_queue[4][0]
		if not is_instance_valid(entry["node"]):
			Global.lane_queue[4].pop_front()
			return
		var note_node :Node2D = entry["node"]
		var note_time_check :float = entry["note_time"]
		var time_diff = abs((note_time_check-Global.song_time)*1000)
		if time_diff >=140:
			return
		if time_diff > 75 and time_diff <140:
			Global.miss +=1
			Global.combo =0
			lane_4.text = "MISS"
		elif time_diff > 20:
			Global.goods +=1
			Global.combo+=1
			Global.score += 50*Global.combo_mult
			lane_4.text = "GOOD"
		elif time_diff <= 20:
			Global.perfects +=1
			Global.combo+=1
			Global.score += 100*Global.combo_mult
			lane_4.text = "PERFECT"
		Global.lane_queue[4].pop_front()
		note_node.queue_free()
		Global.update_mult()
