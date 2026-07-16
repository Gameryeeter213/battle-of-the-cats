extends Node2D

#Create variables
var ReturnScene :String = "res://Scenes/appartment.tscn"
var enemyid :String = ""
@onready var block :PackedScene = preload("res://Scenes/block.tscn")
@onready var audioplayer :AudioStreamPlayer2D = $Music
@onready var lane_0 :Label = $"CanvasLayer/PlayArea/PanelContainer/VBoxContainer/VBoxContainer/Container/HBoxContainer2/Lane 0"
@onready var lane_1 :Label = $"CanvasLayer/PlayArea/PanelContainer/VBoxContainer/VBoxContainer/Container/HBoxContainer2/Lane 1"
@onready var lane_2 :Label = $"CanvasLayer/PlayArea/PanelContainer/VBoxContainer/VBoxContainer/Container/HBoxContainer2/Lane 2"
@onready var lane_3 :Label = $"CanvasLayer/PlayArea/PanelContainer/VBoxContainer/VBoxContainer/Container/HBoxContainer2/Lane 3"
@onready var lane_4 :Label = $"CanvasLayer/PlayArea/PanelContainer/VBoxContainer/VBoxContainer/Container/HBoxContainer2/Lane 4"
@onready var score_board :Label = $CanvasLayer/PlayArea/VBoxContainer/HBoxContainer/Score
@onready var camera :Camera2D = $Camera2D
@onready var lane_0Part :GPUParticles2D = $"Lane 0 Particles"
@onready var lane_1Part :GPUParticles2D = $"Lane 1 Particles"
@onready var lane_2Part :GPUParticles2D = $"Lane 2 Particles"
@onready var lane_3Part :GPUParticles2D = $"Lane 3 Particles"
@onready var lane_4Part :GPUParticles2D = $"Lane 4 Particles"
@onready var BlockLayer :CanvasLayer = $BlockLayer
@export var shake_scale :float = 1.0
@onready var animation :AnimationPlayer = $AnimationPlayer
@onready var sticks := $Sticks
@onready var countin :=$CanvasLayer/PreStart/PanelContainer/Label
@onready var missSFX :=$Miss
var enemyshake :float = 0.0
@onready var enemy :AnimatedSprite2D = $EnemySprite
var attack :bool = false
var defend :bool = false
var heal :bool = false
@onready var playerhealth := $CanvasLayer/Control/PlayerHealth
@onready var enemyhealth := $CanvasLayer/Control/EnemyHealth
var enemy_action :String = ""
var targetPlayer :float = Global.health
var targetEnemy = 1000.0
@onready var EnemyLabel = $CanvasLayer/Results2/MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/Label
@onready var PlayerLabel = $CanvasLayer/Results2/MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/Label2
var failed :bool = false

@onready var hoversfx := $Hover
@onready var selectsfx :AudioStreamPlayer2D = $Select

var win :bool = false

enum State {
	Waiting,
	Playing,
	Action_Selection
}
var state = State.Action_Selection
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
	index = 0
	charts.clear()
	notes.clear()
	animation.play("RESET")

	Rhythm.reset()
	$CatSprite.play("Idle "+Global.cat_color)
	$EnemySprite.play()
	instrument = Global.Instrument

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	enemyhealth.value = lerpf(enemyhealth.value, targetEnemy, 2*delta)
	playerhealth.value = lerpf(playerhealth.value, targetPlayer, 2*delta)
	match state:
		State.Action_Selection:
			return
		State.Waiting:
			Rhythm.miss_shake = lerp(Rhythm.miss_shake, 0.0, 2*delta)
			camera.offset.x += randf_range(-15*shake_scale*Rhythm.miss_shake,15*shake_scale*Rhythm.miss_shake)
		State.Playing:
			play_chart()
			check_held_notes()
			Rhythm.miss_shake = lerp(Rhythm.miss_shake, 0.0, 2*delta)
			enemyshake = lerp(enemyshake, 0.0, 3*delta)
			camera.offset.x += randf_range(-15*shake_scale*Rhythm.miss_shake,15*shake_scale*Rhythm.miss_shake)
			if attack:
				enemy.offset.x += randf_range(-15*0.1*enemyshake,15*0.1*enemyshake)
			score_board.text = str(int(lerp(int(score_board.text), Rhythm.score, 6*delta)))
			audioplayer.volume_linear = lerp(audioplayer.volume_linear, 1.0, delta)
func load_song(path: String):
	charts.clear()
	index = 0
	notes.clear()
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
	Rhythm.song_time = (Time.get_ticks_usec() - time_begin)/ 1000000.0
	Rhythm.song_time -= time_delay
	Rhythm.song_time = max(0, Rhythm.song_time)
	while index < notes.size():
		var note = notes[index]
		note_time = note.beat * 60.0 / bpm
		var hold_time :float = note.duration * 60.0 / bpm
		if Rhythm.song_time+2.0 >= note_time:
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
	Rhythm.lane_queue[lane].append({
		"note_time": note_time,
		"node": Block,
		"duration": hold_time
		})
	BlockLayer.add_child(Block)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_page_down"):
		targetEnemy-=100
	if Input.is_action_just_pressed("ui_accept") && state == State.Waiting:
		if win:
			Global.health = targetPlayer
			var room = load(ReturnScene)
			var room2 = room.instantiate()
			$"../".add_child(room2)
			queue_free()
			
		elif $CanvasLayer/Results.visible:
			selectsfx.play()
			$CanvasLayer/Results.hide()
			$CanvasLayer/Results2.show()
			enemy_choice()
			calculations()
		else:
			selectsfx.play()
			$CanvasLayer/Results2.hide()
			$"CanvasLayer/Action Select".show()
			animation.play("RESET")
			camera.offset.x = 320.0
			state = State.Action_Selection
	
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
	if Rhythm.lane_queue[lane].is_empty():
		return
	var entry = Rhythm.lane_queue[lane][0]
	if not is_instance_valid(entry["node"]):
		Rhythm.lane_queue[lane].pop_front()
		return
	var note_node :Node2D = entry["node"]
	var note_time_check :float = entry["note_time"]
	var time_diff :float = abs((note_time_check-Rhythm.song_time)*1000)
	var duration :float = entry["duration"]
	if time_diff >=140:
		return
	if time_diff > 75 and time_diff <140:
		audioplayer.volume_linear = 0.0
		missSFX.pitch_scale = randf_range(0.9,1.1)
		missSFX.play()
		Rhythm.miss +=1
		Rhythm.miss_shake = 1.0
		Rhythm.combo =0
		lane_label.text = "MISS"
		Rhythm.lane_queue[lane].pop_front()
		note_node.queue_free()
		Rhythm.update_mult()

	elif time_diff > 20:
		Rhythm.goods +=1
		Rhythm.combo+=1
		Rhythm.score += 50*Rhythm.combo_mult
		enemyshake = 0.75
		lane_label.text = "GOOD"
		lane_part.emitting = true
		if duration > 0.0:
			Rhythm.active_hold[lane] = entry
			return
	elif time_diff <= 20:
		enemyshake=1.0
		Rhythm.perfects +=1
		Rhythm.combo+=1
		Rhythm.score += 100*Rhythm.combo_mult
		lane_label.text = "PERFECT"
		lane_part.emitting = true
		if duration > 0.0:
			Rhythm.active_hold[lane] = entry
			return
	if not duration > 0.0:
		Rhythm.lane_queue[lane].pop_front()
		note_node.queue_free()
		Rhythm.update_mult()

func check_held_notes():
	for lane in range(5):
		var hold = Rhythm.active_hold[lane]
		if hold == null:
			continue
		if !Input.is_action_pressed("Lane %d" % lane):
			fail_hold(lane)
			continue
		if Rhythm.song_time >= hold["note_time"] + hold["duration"]:
			complete_hold(lane)

func fail_hold(lane :int):	
	var note_node :Node2D =  Rhythm.active_hold[lane]["node"]
	Rhythm.lane_queue[lane].pop_front()
	Rhythm.miss +=1
	Rhythm.miss_shake = 1.0
	Rhythm.combo =0
	note_node.queue_free()
	Rhythm.update_mult()
	Rhythm.active_hold[lane] = null

func complete_hold(lane :int):
	var note_node :Node2D =  Rhythm.active_hold[lane]["node"]
	var NoteTime :float =  Rhythm.active_hold[lane]["note_time"]
	var Duration :float =  Rhythm.active_hold[lane]["duration"]
	var time_diff :float = abs(NoteTime+Duration-Rhythm.song_time)*1000.0
	if time_diff > 20 and !Input.is_action_pressed("Lane "+str(lane)):
		Rhythm.goods +=1
		Rhythm.combo+=1
		Rhythm.score += 50*Rhythm.combo_mult
		Rhythm.lane_queue[lane].pop_front()
		note_node.queue_free()
		Rhythm.update_mult()
		Rhythm.active_hold[lane] = null
	elif time_diff <= 20 and !Input.is_action_pressed("Lane "+str(lane)):
		Rhythm.perfects +=1
		Rhythm.combo+=1
		Rhythm.score += 100*Rhythm.combo_mult
		Rhythm.lane_queue[lane].pop_front()
		note_node.queue_free()
		Rhythm.update_mult()
		Rhythm.active_hold[lane] = null
	elif time_diff >=140:
		Rhythm.lane_queue[lane].pop_front()
		note_node.queue_free()
		Rhythm.update_mult()
		Rhythm.active_hold[lane] = null

func action_selected(Action :String):
	defend = false
	attack = false
	heal = false
	if Action == "Attack ":
		attack = true
	elif Action == "Defend ":
		defend = true
	elif Action == "Heal ":
		heal = true
	load_song("res://Assets/Tracks/"+Action+Global.Instrument+".JSON")
	audioplayer.stream = load("res://Assets/Tracks/"+Action+Global.Instrument+".mp3")
	notes = charts[instrument]
	animation.play("Hide Action Select")
	await get_tree().create_timer(1).timeout
	$"CanvasLayer/Action Select".hide()
	$CanvasLayer/PreStart.show()
	state = State.Waiting
	count_in()



func _on_attack_pressed() -> void:
	selectsfx.play()
	action_selected("Attack ")


func _on_defend_pressed() -> void:
	selectsfx.play()
	action_selected("Defend ")


func _on_heal_pressed() -> void:
	selectsfx.play()
	action_selected("Heal ")

func count_in():
	enemy.offset = Vector2.ZERO
	Rhythm.miss_shake = 0.0
	enemyshake = 0.0
	audioplayer.volume_linear = 1.0
	Rhythm.reset()
	failed = false
	start_chart()
	state = State.Playing
	$CanvasLayer/PlayArea.show()
	sticks.play()
	countin.text = "1"
	await get_tree().create_timer(60/bpm).timeout
	sticks.play()
	countin.text = "2"
	await get_tree().create_timer(60/bpm).timeout
	sticks.play()
	countin.text = "3"
	await get_tree().create_timer(60/bpm).timeout
	sticks.play()
	countin.text = "4"
	await get_tree().create_timer(60/bpm).timeout
	animation.play("Hide PreStart")
	await get_tree().create_timer(0.5).timeout
	$"CanvasLayer/PreStart".hide()


func _on_music_finished() -> void:
	results_screen()

func results_screen():
	for child in BlockLayer.get_children():
		child.queue_free()
	$CanvasLayer/PlayArea.hide()
	$CanvasLayer/Results.show()
	state = State.Waiting
	var accuracy :float = float(Rhythm.goods + Rhythm.perfects)/float(Rhythm.miss+Rhythm.goods+Rhythm.perfects)
	if attack:
		$"CanvasLayer/Results/MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/Label".text = str(clampi(Rhythm.score-150,0,300))+" Damage"
	elif accuracy >= 0.75:
		$"CanvasLayer/Results/MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/Label".text = str(accuracy*100)+"%: Pass"
		failed = false
	else:
		$"CanvasLayer/Results/MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/Label".text = str(accuracy*100)+" Fail"
		failed = true
	$CanvasLayer/Results/MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/Label2.text = str(Rhythm.perfects)+" Perfect"
	$CanvasLayer/Results/MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/Label3.text = str(Rhythm.goods)+" Good"
	$CanvasLayer/Results/MarginContainer/PanelContainer/HBoxContainer/VBoxContainer/Label4.text = str(Rhythm.miss)+" Miss"
	lane_0.text = ""
	lane_1.text = ""
	lane_2.text = ""
	lane_3.text = ""
	lane_4.text = ""

func enemy_choice():
	var choice = randi_range(1,4)
	if choice == 4:
		enemy_action = "Defend"
	else:
		enemy_action = "Attack"



func calculations():
	if enemy_action == "Defend" && defend && !failed:
		EnemyLabel.text = "Enemy Defends"
		PlayerLabel.text = "Do something"
	elif enemy_action == "Defend" && defend && failed:
		EnemyLabel.text = "Enemy Defends"
		PlayerLabel.text = "Lucky... for now"
	elif enemy_action == "Defend" && attack:
		EnemyLabel.text = "Enemy Defends"
		PlayerLabel.text = "Womp Womp"
		Rhythm.miss_shake=0.25
	elif enemy_action == "Defend" && heal && failed:
		EnemyLabel.text = "Enemy Defends"
		PlayerLabel.text = "You failure"
	elif enemy_action == "Defend" && heal && !failed:
		EnemyLabel.text = "Enemy Defends"
		PlayerLabel.text = "You did it!"
		targetPlayer+=175
	elif enemy_action == "Attack" && heal && failed:
		EnemyLabel.text = "Enemy Attacks"
		PlayerLabel.text = "lol"
		Rhythm.miss_shake=0.5
		targetPlayer -=randi_range(150,250)
	elif enemy_action == "Attack" && heal && !failed:
		EnemyLabel.text = "Enemy Attacks"
		PlayerLabel.text = "hmmmmm"
		Rhythm.miss_shake=0.5
		targetPlayer +=randi_range(150,225)
	elif enemy_action == "Attack" && defend && failed:
		EnemyLabel.text = "Enemy Attacks"
		PlayerLabel.text = "Maybe... nah"
		Rhythm.miss_shake=0.5
		targetPlayer -=randi_range(150,250)
	elif enemy_action == "Attack" && defend && !failed:
		EnemyLabel.text = "Enemy Attacks"
		PlayerLabel.text = "Good Job!"
		Rhythm.miss_shake=0.5
	elif enemy_action == "Attack" && attack:
		EnemyLabel.text = "Enemy Attacks"
		PlayerLabel.text = "Clash!"
		Rhythm.miss_shake=0.5
		targetPlayer-=randi_range(150,250)
		targetEnemy -= clampi(Rhythm.score-150,0,300)
	if targetPlayer <= 0:
		get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
	elif targetPlayer >1000.0:
		targetPlayer = 1000.0
	if targetEnemy <=0.0:
		state = State.Action_Selection
		EnemyLabel.text = "Enemy Defeated"
		PlayerLabel.text = "Yippee"
		win = true
		state = State.Waiting
		ID.defeated_enemies.append(enemyid)
		

func _on_attack_mouse_entered() -> void:
	hoversfx.play()


func _on_defend_mouse_entered() -> void:
	hoversfx.play()

func _on_heal_mouse_entered() -> void:
	hoversfx.play()
