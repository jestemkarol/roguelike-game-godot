extends CharacterBody2D

@onready var just_hit_timer: Timer = $just_hit_timer
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_cooldown_timer: Timer = $attack_cooldown_timer

@export var speed = 50
@export var health = 50
var player_chase = false
var player = null
var direction = Vector2.ZERO
var just_hit = false
var attack_cooldown_on = false
var is_attacking = false
var dead = false

func _ready() -> void:
	animation_player.play('idle_down')

func _physics_process(delta: float) -> void:
	if dead:
		return
	if is_attacking:
		attack_cooldown_on = true
		attack_cooldown_timer.start()
		play_animation('attack')
		attack_charge()
		player.hit(10, direction)
	if player_chase:
		if !is_attacking:
			direction = (player.get_global_position() - position).normalized()
			velocity = direction * speed * delta
			play_animation('move')
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.07)
	move_and_collide(velocity)

func _on_detection_area_body_entered(body: Node2D) -> void:
	if dead:
		return
	if body.is_in_group('player'):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group('player'):
		player = null
		player_chase = false
		
func play_animation(type: String) -> void:
	animation_player.flip_h = false
	if direction.y > direction.x && direction.y > -direction.x:
		animation_player.play('%s_down' % type)
	elif direction.y > direction.x && direction.y < -direction.x:
		animation_player.flip_h = true
		animation_player.play('%s_side' % type)
	elif direction.y < direction.x && direction.y < -direction.x:
		animation_player.play('%s_up' % type)
	elif direction.y < direction.x && direction.y > -direction.x:
		animation_player.play('%s_side' % type)

func hit(damage: int):
	if !just_hit:
		just_hit = true
		just_hit_timer.start()
		health -= damage
		print("Enemy health: %s" % health)
		if health < 0:
			death()
		knockback()

func knockback():
	var tween = create_tween()
	tween.tween_property(self, 'global_position', global_position - direction * 25, 0.2)

func attack_charge():
	var tween = create_tween()
	tween.tween_property(self, 'global_position', global_position + direction * 12, 0.2)

func death():
	dead = true
	animation_player.play('death')
	await get_tree().create_timer(3).timeout
	queue_free()

func _on_just_hit_timer_timeout() -> void:
	just_hit = false

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		is_attacking = true
		player = body

func _on_attack_cooldown_timer_timeout() -> void:
	attack_cooldown_on = false

func _on_animated_sprite_2d_animation_finished() -> void:
	is_attacking = false
