extends Control

@onready var sprites := [
	$"Calico Sprite",
	$"White Sprite",
	$"Orange Sprite",
	$"Black Sprite",
	$"Siamese Sprite"
]

@onready var music :AudioStreamPlayer2D = $"../Music"
@onready var world := preload("res://Scenes/world.tscn")
@onready var hoversfx :AudioStreamPlayer2D = $"../Hover"
@onready var selectsfx :AudioStreamPlayer2D = $"../Select"
@onready var arrowsfx := $ArrowSFX

var characters := [
	"Calico",
	"White",
	"Orange",
	"Black",
	"Siamese"
]

@onready var CatName :Label = $Label

var index: int = 0
var speed: float = 8.0

var center_x := 320
var center_y := 180
var spacing := 96
var center_scale := 6.0
var side_scale := 3.0


func _ready() -> void:
	for i in range(len(sprites)):
		sprites[i].play("Idle")
	apply_focus()

func _process(delta: float) -> void:
	for i in sprites.size():
		var sprite = sprites[i]

		var offset_index = i - index

		var target_pos = Vector2(center_x + offset_index * spacing, center_y)

		var target_scale = Vector2(
			center_scale if i == index else side_scale,
			center_scale if i == index else side_scale
		)

		sprite.position = sprite.position.lerp(target_pos, speed * delta)
		sprite.scale = sprite.scale.lerp(target_scale, speed * delta)


func _on_right_pressed() -> void:
	arrowsfx.pitch_scale = randf_range(0.9,1.1)
	arrowsfx.play()
	index = (index + 1) % sprites.size()
	apply_focus()


func _on_left_pressed() -> void:
	arrowsfx.pitch_scale = randf_range(0.9,1.1)
	arrowsfx.play()
	index = (index - 1 + sprites.size()) % sprites.size()
	apply_focus()


func apply_focus() -> void:
	CatName.text = characters[index]


func _on_button_pressed() -> void:
	selectsfx.play()
	Global.cat_color = characters[index]
	characters.remove_at(index)
	Global.characters = characters
	var tween = create_tween()
	tween.tween_property(
		music,
		"volume_db",
		-8.0,
		0.4
	)
	await tween.finished
	music.stop()
	music.volume_db = 0
	get_tree().change_scene_to_packed(world)


func _on_left_mouse_entered() -> void:
	hoversfx.pitch_scale = randf_range(0.9,1.1)
	hoversfx.play()


func _on_right_mouse_entered() -> void:
	hoversfx.pitch_scale = randf_range(0.9,1.1)
	hoversfx.play()


func _on_button_mouse_entered() -> void:
	hoversfx.pitch_scale = randf_range(0.9,1.1)
	hoversfx.play()
