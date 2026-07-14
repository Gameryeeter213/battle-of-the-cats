extends CharacterBody2D

@onready var Cat := $CatSprite
@onready var game := preload("res://Scenes/rythm_demo.tscn")

const SPEED = 115.0



func _physics_process(delta: float) -> void:
	var directionx := Input.get_axis("ui_left", "ui_right")
	var directiony := Input.get_axis("ui_up", "ui_down")

	velocity = Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		velocity.y = -SPEED
	elif Input.is_action_pressed("ui_down"):
		velocity.y = SPEED
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x = SPEED
	if velocity == Vector2.ZERO:
		Cat.play("Idle " + Global.cat_color)
	else:
		Cat.stop()

	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		get_tree().change_scene_to_packed(game)
