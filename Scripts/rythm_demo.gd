extends Node2D

#Create variables
var bpm: float = 120.0
var instrument := ""
var charts := {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play()
	$AnimatedSprite2D2.play()
	load_song("res://Assets/Tracks/Crazy Train.JSON")
	instrument = "Guitar"
	print(charts[instrument])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
