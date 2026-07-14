extends Control
@onready var menu:=$MenuLayer
@onready var select := $"Character Selector"
@onready var hoversfx := $Hover
@onready var selectsfx :AudioStreamPlayer2D = $Select
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	selectsfx.play()
	menu.hide()
	select.show()


func _on_button_mouse_entered() -> void:
	hoversfx.pitch_scale = randf_range(0.9,1.1)
	hoversfx.play()
