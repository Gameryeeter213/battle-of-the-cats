extends Node2D

@onready var enemy := preload("res://Scenes/enemy.tscn")

func _ready() -> void:
	print(ID.defeated_enemies)
	if not "floor_1_appart" in ID.defeated_enemies:
		var enemy1 = enemy.instantiate()
		enemy1.global_position = Vector2(4,20)
		enemy1.id = "floor_1_appart"
		add_child(enemy1)
