extends Node2D

var dialogue = load("res://Venue.dialogue")
@onready var final = load("res://Scenes/final_show.tscn")
@onready var map = load("res://Scenes/map.tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$Player.can_move = false
		$"../Music".set_volume_linear(0.15)
		if !Global.drummer or !Global.guitarist:
			DialogueManager.show_dialogue_balloon(dialogue, "fail")
		else:
			DialogueManager.show_dialogue_balloon(dialogue, "pass")
		await get_tree().create_timer(2).timeout
		await $"../ExampleBalloon".tree_exited
		$"../Music".set_volume_linear(1)
		$Player.global_position = Vector2(0,-80)
		$Player.can_move = true
		if Global.drummer && Global.guitarist:
			get_tree().change_scene_to_packed(final)


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var room = map.instantiate()
		room.find_child("Player").global_position = Vector2(-80,-60)
		get_parent().add_child(room)
		queue_free()
