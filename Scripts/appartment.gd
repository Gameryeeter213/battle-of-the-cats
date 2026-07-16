extends Node2D

@onready var enemy := load("res://Scenes/enemy.tscn")
@onready var appartment2 := load("res://Scenes/appartment_2.tscn")
@onready var map := load("res://Scenes/map.tscn")
func _ready() -> void:
	$"Player".room = "res://Scenes/appartment.tscn"
	if not "floor_1_appart" in ID.defeated_enemies:
		var enemy1 = enemy.instantiate()
		enemy1.global_position = Vector2(4,20)
		enemy1.id = "floor_1_appart"
		add_child(enemy1)
	$"../Music".volume_linear =1.0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Open_Appartment2()

func Open_Appartment2():
	var room = appartment2.instantiate()
	get_parent().add_child(room)
	queue_free()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var room = map.instantiate()
		room.find_child("Player").global_position = Vector2(-160,-70)
		get_parent().add_child(room)
		queue_free()
