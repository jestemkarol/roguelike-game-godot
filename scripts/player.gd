extends CharacterBody2D

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var just_hit_timer: Timer = $just_hit_timer
@onready var deal_attack_timer: Timer = $deal_attack_timer
@onready var player_hitbox: Area2D = $player_hitbox

@export var speed = 100
@export var health = 100
var input_direction = Vector2.ZERO
var current_dir = 'down'
var enemy_in_attack_range = false
var just_hit = false
var is_attacking = false
var dead = false
var enemy = null
var knockback_direction = Vector2.ZERO
var knockback_force = 200
var knockback_weight = 0.1
var knocked_back = false
var in_knockback_state = false

func _ready() -> void:
	animation_player.play('idle_down')

func _physics_process(delta: float) -> void:
	player_movement(delta)
	
func player_movement(delta: float) -> void:
	if in_knockback_state:
		apply_knockback(delta)
	else:
		normal_movement(delta)

	move_and_slide()

func apply_knockback(delta):
	if knockback_direction.length() > 0.01:  # Small threshold to stop knockback
		knockback_direction = lerp(knockback_direction, Vector2.ZERO, knockback_weight)
		velocity = knockback_direction * knockback_force
	else:
		in_knockback_state = false
		knockback_direction = Vector2.ZERO
		velocity = Vector2.ZERO

	#if !(knockback_direction.abs().x < 0.00001 && knockback_direction.abs().y < 0.00001):
		#print("kd: %s, p: %s, lerp: %s" % [knockback_direction * knockback_force, position, lerp(knockback_direction * knockback_force, Vector2.ZERO, knockback_weight)])
		#knockback_direction = lerp(knockback_direction * knockback_force, Vector2.ZERO, knockback_weight)
		#print('Assumed velocity %s' % Vector2(knockback_direction.x * knockback_force, knockback_direction.y * knockback_force))
		#velocity = Vector2(knockback_direction.x * knockback_force, knockback_direction.y * knockback_force)
		#print(velocity)
		#velocity = lerp(Vector2.ZERO, knockback_direction - position, 0.1)
		#knockback_direction = velocity
		#move_and_slide()
		#if knockback_direction == Vector2(-0, 0):
			#in_knockback_state = false
		#return
func normal_movement(delta):
	if Input.is_action_pressed('attack'):
		attack()
	input_direction = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
	velocity = movement()

func play_movement_animation(type: String) -> void:
	if input_direction.y > input_direction.x && input_direction.y > -input_direction.x:
		animation_player.flip_h = false
		current_dir = 'down'
		animation_player.play('%s_down' % type)
	elif input_direction.y > input_direction.x && input_direction.y < -input_direction.x:
		animation_player.flip_h = true
		current_dir = 'left'
		animation_player.play('%s_side' % type)
	elif input_direction.y < input_direction.x && input_direction.y < -input_direction.x:
		animation_player.flip_h = false
		current_dir = 'up'
		animation_player.play('%s_up' % type)
	elif input_direction.y < input_direction.x && input_direction.y > -input_direction.x:
		animation_player.flip_h = false
		current_dir = 'right'
		animation_player.play('%s_side' % type)
	switch_hitbox_shape(current_dir)

func attack() -> void:
	is_attacking = true
	deal_attack_timer.start()
	play_animation('attack')
	if enemy:
		enemy.hit(20)

func movement():
	if is_attacking:
		return Vector2.ZERO
	if input_direction != Vector2.ZERO:
		play_movement_animation('move')
	else:
		play_animation('idle')
	return input_direction * speed

func switch_hitbox_shape(direction):
	for shape in player_hitbox.get_children():
		shape.disabled = true
	player_hitbox.get_node(direction).disabled = false

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
		print('knockback')
		knockback_direction = hit_direction
		print("Player health: %s" % health)
		if health < 0:
			death()

func knockback():
	if knocked_back:
		return
	knocked_back = true
	in_knockback_state = true
	#var tween = create_tween()
	#tween.tween_property(self, 'global_position', global_position + knockback_direction * 15, 0.2)
	await get_tree().create_timer(1).timeout
	knocked_back = false

func death():
	print('bye')

func _on_just_hit_timer_timeout() -> void:
	just_hit = false

func _on_deal_attack_timer_timeout() -> void:
	is_attacking = false

func _on_player_knockback_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group('enemy') && just_hit && !knocked_back:
		knockback()
