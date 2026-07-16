extends Node2D

var dialogue = load("res://Drummer.dialogue")


@onready var map = load("res://Scenes/map.tscn")
@onready var enemy := load("res://Scenes/enemy.tscn")

func _ready() -> void:
	$"Player".room = "res://Scenes/store.tscn"
	if not "store1" in ID.defeated_enemies:
		var enemy1 = enemy.instantiate()
		enemy1.global_position = Vector2(13,23)
		enemy1.id = "store1"
		add_child(enemy1)
	if not "store2" in ID.defeated_enemies:
		var enemy1 = enemy.instantiate()
		enemy1.global_position = Vector2(-360,9)
		enemy1.id = "store2"
		add_child(enemy1)
	$"../Music".volume_linear =1.0
	if Global.Drum_color == "":
		var rand =randi_range(0,3)
		Global.Drum_color = Global.characters[rand]
		Global.characters.remove_at(rand)
	$CatSprite.play("Idle "+Global.Drum_color)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var room = map.instantiate()
		room.find_child("Player").global_position = Vector2(-270,-70)
		get_parent().add_child(room)
		queue_free()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$Player.can_move = false
		$"../Music".set_volume_linear(0.15)
		if !Global.drummer:
			DialogueManager.show_dialogue_balloon(dialogue, "start")
			Global.drummer = true
		elif Global.drummer:
			DialogueManager.show_dialogue_balloon(dialogue, "again")
		await get_tree().create_timer(2).timeout
		await $"../ExampleBalloon".tree_exited
		$"../Music".set_volume_linear(1)
		$Player.global_position = Vector2(-470,95)
		$Player.can_move = true
