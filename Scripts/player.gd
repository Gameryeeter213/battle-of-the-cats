extends CharacterBody2D

@onready var Cat := $CatSprite

const SPEED = 100.0


func _physics_process(delta: float) -> void:
	
	var directionx := Input.get_axis("ui_left", "ui_right")
	var directiony := Input.get_axis("ui_up", "ui_down")
	
	if directiony:
		velocity.y = directiony * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	if directionx:
		velocity.x = directionx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity == Vector2(0.0,0.0):
		Cat.play("Idle")
	else:
		Cat.stop()
	move_and_slide()
