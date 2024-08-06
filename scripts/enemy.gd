extends CharacterBody2D

@onready var just_hit_timer: Timer = $just_hit_timer
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_cooldown_timer: Timer = $attack_cooldown_timer

@export var speed: int = 80
@export var health: int = 50
@export var hit_damage: int = 10

const PlayerGroupName: String = 'player'

const IdleAnimationNames: Dictionary = { 
	DOWN = 'idle_down', SIDE = 'idle_side', UP = 'idle_up' 
}
const AttackAnimationNames: Dictionary = { 
	DOWN = 'attack_down', SIDE = 'attack_side', UP = 'attack_up' 
}
const MoveAnimationNames: Dictionary = { 
	DOWN = 'move_down', SIDE = 'move_side', UP = 'move_up' 
}
const AnimationNames: Dictionary = {
	IDLE = IdleAnimationNames, 
	ATTACK = AttackAnimationNames, 
	MOVE = MoveAnimationNames,
	DEATH = 'death'
}

# enemy state
var player_chase: bool = false
var dead: bool = false

# attack-related variables
var attack_cooldown_on: bool = false
var is_attacking: bool = false
var player: CharacterBody2D = null
var direction = Vector2.ZERO
var just_hit: bool = false

# knockback-related variables
var knockback_direction: Vector2 = Vector2.ZERO
var knockback_force: int = 30
var knockback_acceleration: int = 10
var knockback_weight: float = 0.1
var in_knockback_state: bool = false

func _ready() -> void:
	animation_player.play(AnimationNames.IDLE.DOWN)

func _physics_process(delta: float) -> void:
	if dead:
		return
	elif in_knockback_state:
		velocity = apply_knockback(delta)
	elif is_attacking:
		attack_cooldown_on = true
		attack_cooldown_timer.start()
		play_animation(AttackAnimationNames)
		if player:
			player.hit(hit_damage)
			player.knockback(direction)
	elif player_chase:
		if !is_attacking:
			direction = (player.get_global_position() - position).normalized()
			velocity = direction * speed * delta
			play_animation(MoveAnimationNames)
	else:
		play_animation(IdleAnimationNames)
		velocity = lerp(velocity, Vector2.ZERO, 0.07)
	move_and_collide(velocity)

func play_animation(animation_stash: Dictionary) -> void:
	animation_player.flip_h = false
	if direction.y > direction.x && direction.y > -direction.x:
		animation_player.play(animation_stash.DOWN)
	elif direction.y > direction.x && direction.y < -direction.x:
		animation_player.flip_h = true
		animation_player.play(animation_stash.SIDE)
	elif direction.y < direction.x && direction.y < -direction.x:
		animation_player.play(animation_stash.UP)
	elif direction.y < direction.x && direction.y > -direction.x:
		animation_player.play(animation_stash.SIDE)

func hit(damage: int) -> void:
	if !just_hit && !dead:
		just_hit = true
		just_hit_timer.start()
		health -= damage
		print("Enemy health: %s" % health)
		if health < 0:
			death()

func apply_knockback(delta: float) -> Vector2:
	if knockback_direction.length() > 0.01:  # Small threshold to stop knockback
		knockback_direction = lerp(knockback_direction, Vector2.ZERO, knockback_weight)
		return knockback_direction * knockback_force * knockback_acceleration * delta
	else:
		in_knockback_state = false
		knockback_direction = Vector2.ZERO
		return Vector2.ZERO


func knockback(hit_direction: Vector2) -> void:
	if in_knockback_state:
		return
	knockback_direction = hit_direction
	in_knockback_state = true
	await get_tree().create_timer(1).timeout
	in_knockback_state = false

func death() -> void:
	dead = true
	animation_player.play(AnimationNames.DEATH)
	await get_tree().create_timer(3).timeout
	queue_free()

func _on_detection_area_body_entered(body: Node2D) -> void:
	if dead:
		return
	if body.is_in_group(PlayerGroupName):
		player = body
		player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group(PlayerGroupName):
		player = null
		player_chase = false
		
func _on_just_hit_timer_timeout() -> void:
	just_hit = false

func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group(PlayerGroupName):
		is_attacking = true
		player = body

func _on_attack_cooldown_timer_timeout() -> void:
	attack_cooldown_on = false

func _on_animated_sprite_2d_animation_finished() -> void:
	is_attacking = false
