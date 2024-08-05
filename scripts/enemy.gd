extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 50
var player_chase = false
var player = null
var direction = Vector2.ZERO

func _ready() -> void:
	$AnimatedSprite2D.play('idle_down')

func _physics_process(delta: float) -> void:
	if player_chase:
		direction = (player.get_global_position() - position).normalized()
		velocity = direction * speed * delta
		play_animation(direction)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.07)
	move_and_collide(velocity)
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		player = null
		player_chase = false
		
func play_animation(direction: Vector2) -> void:
	$AnimatedSprite2D.flip_h = false
	if direction.y > direction.x && direction.y > -direction.x:
		$AnimatedSprite2D.play('move_down')
	elif direction.y > direction.x && direction.y < -direction.x:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play('move_side')
	elif direction.y < direction.x && direction.y < -direction.x:
		$AnimatedSprite2D.play('move_up')
	elif direction.y < direction.x && direction.y > -direction.x:
		$AnimatedSprite2D.play('move_side')
