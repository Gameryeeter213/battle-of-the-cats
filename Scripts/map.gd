extends Node2D

var appartment = preload("res://Scenes/appartment.tscn")
@onready var player = $Player
func _ready() -> void:
	player.global_position = Global.pos
func Open_Appartment():
	var room = appartment.instantiate()
	get_parent().add_child(room)
	Global.pos = player.global_position
	queue_free()


func _on_apartments_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Open_Appartment()
