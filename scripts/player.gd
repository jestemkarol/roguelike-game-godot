extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 100
var current_dir = 'down'

func _ready() -> void:
	$AnimatedSprite2D.play('idle_down')

func _physics_process(delta: float) -> void:
	player_movement(delta)
	
func player_movement(delta: float) -> void:
	if Input.is_action_pressed('move_right'):
		play_animation(1)
		current_dir = 'right'
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed('move_left'):
		play_animation(1)
		current_dir = 'left'
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed('move_down'):
		play_animation(1)
		current_dir = 'down'
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed('move_up'):
		play_animation(1)
		current_dir = 'up'
		velocity.x = 0
		velocity.y = -speed
	else:
		play_animation(0)
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()

func play_animation(movement):
	var dir = current_dir
	
	if dir == 'right':
		$AnimatedSprite2D.flip_h = false
		if movement == 1:
			$AnimatedSprite2D.play('move_side')
		elif movement == 0:
			$AnimatedSprite2D.play('idle_side')
	if dir == 'left':
		$AnimatedSprite2D.flip_h = true
		if movement == 1:
			$AnimatedSprite2D.play('move_side')
		elif movement == 0:
			$AnimatedSprite2D.play('idle_side')
	if dir == 'down':
		$AnimatedSprite2D.flip_h = false
		if movement == 1:
			$AnimatedSprite2D.play('move_down')
		elif movement == 0:
			$AnimatedSprite2D.play('idle_down')
	if dir == 'up':
		$AnimatedSprite2D.flip_h = false
		if movement == 1:
			$AnimatedSprite2D.play('move_up')
		elif movement == 0:
			$AnimatedSprite2D.play('idle_up')
