extends Control

@onready var sprites := [
	$"Calico Sprite",
	$"White Sprite",
	$"Orange Sprite"
]


var characters := [
	"Calico",
	"White",
	"Orange"
]

@onready var CatName :Label = $Label

var index: int = 0
var speed: float = 8.0

# Target layout for each character slot
var targets := [
	{
		"pos": Vector2(224, 180),
		"scale": Vector2(3, 3)
	},
	{
		"pos": Vector2(320, 180),
		"scale": Vector2(6, 6) # center (selected look)
	},
	{
		"pos": Vector2(416, 180),
		"scale": Vector2(3, 3)
	}
]


func _ready() -> void:
	for i in range(len(sprites)):
		sprites[i].play("Idle")
	apply_focus()
	print(index)


func _process(delta: float) -> void:
	# Smoothly move all sprites toward their targets
	for i in sprites.size():
		var sprite = sprites[i]
		var target = targets[i]

		sprite.position = sprite.position.lerp(target["pos"], speed * delta)
		sprite.scale = sprite.scale.lerp(target["scale"], speed * delta)


func _on_right_pressed() -> void:
	index = (index + 1) % sprites.size()
	apply_focus()


func _on_left_pressed() -> void:
	index = (index - 1 + sprites.size()) % sprites.size()
	apply_focus()


func apply_focus() -> void:
	# Rebuild layout so selected character is always centered
	for i in sprites.size():
		if i == index:
			targets[i]["pos"] = Vector2(320, 180)
			targets[i]["scale"] = Vector2(6, 6)
		else:
			# spread left/right around center
			var offset = (i - index) * 96
			targets[i]["pos"] = Vector2(320 + offset, 180)
			targets[i]["scale"] = Vector2(3, 3)
	CatName.text = characters[index]
