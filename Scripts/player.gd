extends CharacterBody2D
var room :String = "res://Scenes/appartment.tscn"
@onready var Cat := $CatSprite
@onready var game := preload("res://Scenes/rythm_demo.tscn")
@onready var music :AudioStreamPlayer2D = $"../../Music"
const SPEED = 115.0
var can_move = true
func _ready() -> void:
	Cat.play("Idle " + Global.cat_color)

func _physics_process(delta: float) -> void:
	if !can_move:
		velocity = Vector2.ZERO
		Cat.play("Idle "+Global.cat_color)
		move_and_slide()
		return
	else:
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
		var tween = create_tween()
		tween.tween_property(
			music,
			"volume_linear",
			 0.0,
			0.4
		)
		await tween.finished
		music.volume_linear = (0)
		body.queue_free()
		open_game(body.id,room)
		

func open_game(id : String, roomid :String):
	var game1 = game.instantiate()
	game1.enemyid = id
	game1.ReturnScene = roomid
	$"../../".add_child(game1)
	
	$"../".queue_free()
