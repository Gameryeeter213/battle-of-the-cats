extends Node2D

@onready var appartment = load("res://Scenes/appartment.tscn")
@onready var store = load("res://Scenes/store.tscn")
@onready var venue = load("res://Scenes/venue.tscn")
@onready var player = $Player
func Open_Appartment():
	var room = appartment.instantiate()
	get_parent().add_child(room)
	queue_free()


func _on_apartments_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Open_Appartment()


func _on_store_area_entered(area: Area2D) -> void:
	var room = store.instantiate()
	get_parent().add_child(room)
	queue_free()


func _on_venue_body_entered(body: Node2D) -> void:
	var room = venue.instantiate()
	get_parent().add_child(room)
	queue_free()
