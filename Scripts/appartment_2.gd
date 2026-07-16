extends Node2D
@onready var Guitar := load("res://Scenes/guitar_room.tscn")

@onready var enemy := load("res://Scenes/enemy.tscn")
@onready var appartment1 := load("res://Scenes/appartment.tscn")
func _ready() -> void:
	$"Player".room = "res://Scenes/appartment_2.tscn"
	if not "floor_2_appart" in ID.defeated_enemies:
		var enemy1 = enemy.instantiate()
		enemy1.global_position = Vector2(230,30)
		enemy1.id = "floor_2_appart"
		add_child(enemy1)
	$"../Music".volume_linear =1.0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Open_guitar()

func Open_guitar():
	var room = Guitar.instantiate()
	get_parent().add_child(room)
	queue_free()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var room = appartment1.instantiate()
		room.find_child("Player").global_position = Vector2(52,7)
		get_parent().add_child(room)
		queue_free()
