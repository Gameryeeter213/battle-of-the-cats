extends Node2D

var dialogue = load("res://Guitarist.dialogue")
var appartment2 = load("res://Scenes/appartment_2.tscn")

func _ready() -> void:
	if Global.Guitar_color =="":
		var rand =randi_range(0,3)
		Global.Guitar_color = Global.characters[rand]
		Global.characters.remove_at(rand)
	$CatSprite.play("Idle "+Global.Guitar_color)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$Player.can_move = false
		$"../Music".set_volume_linear(0.15)
		if !Global.guitarist:
			DialogueManager.show_dialogue_balloon(dialogue, "start")
			Global.guitarist = true
		elif Global.guitarist:
			DialogueManager.show_dialogue_balloon(dialogue, "again")
		await get_tree().create_timer(2).timeout
		await $"../ExampleBalloon".tree_exited
		$"../Music".set_volume_linear(1)
		$Player.global_position = Vector2(0,-80)
		$Player.can_move = true


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var room = appartment2.instantiate()
		room.find_child("Player").global_position = Vector2(280,6)
		get_parent().add_child(room)
		queue_free()
