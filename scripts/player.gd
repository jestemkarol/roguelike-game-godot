extends CharacterBody2D

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var just_hit_timer: Timer = $just_hit_timer
@onready var deal_attack_timer: Timer = $deal_attack_timer
@onready var player_hitbox: Area2D = $player_hitbox

@export var speed = 100
@export var health = 100
var current_dir = 'down'
var enemy_in_attack_range = false
var just_hit = false
var is_attacking = false
var dead = false
var enemy = null
var knockback_direction = Vector2.ZERO
var knocked_back = false

func _ready() -> void:
	animation_player.play('idle_down')

func _physics_process(delta: float) -> void:
	player_movement(delta)
	
func player_movement(delta: float) -> void:
	if Input.is_action_pressed('attack'):
		attack()
	if Input.is_action_pressed('move_right'):
		velocity = movement('right', 'move', speed, 0)
	elif Input.is_action_pressed('move_left'):
		velocity = movement('left', 'move', -speed, 0)
	elif Input.is_action_pressed('move_down'):
		velocity = movement('down', 'move', 0, speed)
	elif Input.is_action_pressed('move_up'):
		velocity = movement('up', 'move', 0, -speed)
	else:
		velocity = idle()
	move_and_slide()

func attack() -> void:
	is_attacking = true
	deal_attack_timer.start()
	play_animation('attack')
	if enemy:
		enemy.hit(20)

func movement(direction: String, animation_type: String, x: int, y: int) -> Vector2:
	if is_attacking:
		return Vector2.ZERO
	switch_hitbox_shape(direction)
	current_dir = direction
	play_animation(animation_type)
	return Vector2(x, y)

func switch_hitbox_shape(direction):
	for shape in player_hitbox.get_children():
		shape.disabled = true
	player_hitbox.get_node(direction).disabled = false

func idle() -> Vector2:
	if is_attacking:
		return Vector2.ZERO
	play_animation('idle')
	return Vector2.ZERO

func play_animation(type):
	var dir = current_dir
	if current_dir == 'left':
		animation_player.flip_h = true
		dir = 'side'
	elif current_dir == 'right':
		animation_player.flip_h = false
		dir = 'side'
	animation_player.play("%s_%s" % [type, dir])

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group('enemy'):
		enemy = body

func hit(damage: int, hit_direction: Vector2):
	if !just_hit:
		just_hit = true
		just_hit_timer.start()
		health -= damage
		knockback_direction = hit_direction
		print("Player health: %s" % health)
		if health < 0:
			death()

func knockback():
	if knocked_back:
		return
	knocked_back = true
	var tween = create_tween()
	tween.tween_property(self, 'global_position', global_position + knockback_direction * 15, 0.2)
	await get_tree().create_timer(0.2).timeout
	knocked_back = false

func death():
	print('bye')

func _on_just_hit_timer_timeout() -> void:
	just_hit = false

func _on_deal_attack_timer_timeout() -> void:
	is_attacking = false

func _on_player_knockback_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group('enemy') && just_hit:
		knockback()
