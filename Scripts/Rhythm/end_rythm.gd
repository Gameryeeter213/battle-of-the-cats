extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	draw_scores()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func draw_scores():
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Miss.text=str(Rhythm.miss)
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Good.text = str(Rhythm.goods)
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/Perfect.text = str(Rhythm.perfects)
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer4/Score.text = str(Rhythm.score)
