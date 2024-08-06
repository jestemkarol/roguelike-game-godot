extends CharacterBody2D

@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
@onready var just_hit_timer: Timer = $just_hit_timer
@onready var deal_attack_timer: Timer = $deal_attack_timer
@onready var player_hitbox: Area2D = $player_hitbox

@export var speed = 100
@export var health = 100

const EnemyGroupName: String = 'enemy'
const Directions: Dictionary = {DOWN = 'down', UP = 'up', RIGHT = 'right', LEFT = 'left'}

# animation names
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
	MOVE = MoveAnimationNames
}

# direction variables
var input_direction: Vector2 = Vector2.ZERO
var current_dir: String = Directions.DOWN
# player state
var dead: bool = false

# attack-related variables
var enemy: CharacterBody2D = null
var enemy_in_attack_range: bool = false
var just_hit: bool = false
var is_attacking: bool = false

# knockback variables
var knockback_direction: Vector2 = Vector2.ZERO
var knockback_force: int = 200
var knockback_weight: float = 0.1
var in_knockback_state: bool = false

func _ready() -> void:
	animation_player.play(AnimationNames.IDLE.DOWN)

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

func normal_movement(delta):
	if Input.is_action_pressed('attack'):
		attack()
	input_direction = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')
	velocity = movement()

func play_movement_animation() -> void:
	if input_direction.y > input_direction.x && input_direction.y > -input_direction.x:
		animation_player.flip_h = false
		current_dir = Directions.DOWN
		animation_player.play(AnimationNames.MOVE.DOWN)
	elif input_direction.y > input_direction.x && input_direction.y < -input_direction.x:
		animation_player.flip_h = true
		current_dir = Directions.LEFT
		animation_player.play(AnimationNames.MOVE.SIDE)
	elif input_direction.y < input_direction.x && input_direction.y < -input_direction.x:
		animation_player.flip_h = false
		current_dir = Directions.UP
		animation_player.play(AnimationNames.MOVE.UP)
	elif input_direction.y < input_direction.x && input_direction.y > -input_direction.x:
		animation_player.flip_h = false
		current_dir = Directions.RIGHT
		animation_player.play(AnimationNames.MOVE.SIDE)
	switch_hitbox_shape(current_dir)

func attack() -> void:
	is_attacking = true
	deal_attack_timer.start()
	play_animation(AnimationNames.ATTACK)
	if enemy:
		enemy.hit(20, (enemy.get_global_position() - position).normalized())

func movement():
	if is_attacking:
		return Vector2.ZERO
	if input_direction != Vector2.ZERO:
		play_movement_animation()
	else:
		play_animation(AnimationNames.IDLE)
	return input_direction * speed

func switch_hitbox_shape(direction):
	for shape in player_hitbox.get_children():
		shape.disabled = true
	player_hitbox.get_node(direction).disabled = false

func play_animation(animation_stash):
	var dir = current_dir.to_upper()
	if current_dir == Directions.LEFT:
		animation_player.flip_h = true
		dir = 'SIDE'
	elif current_dir == Directions.RIGHT:
		animation_player.flip_h = false
		dir = 'SIDE'
	animation_player.play(animation_stash.get(dir))

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group(EnemyGroupName):
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

func death():
	print('bye')

func _on_just_hit_timer_timeout() -> void:
	just_hit = false

func _on_deal_attack_timer_timeout() -> void:
	is_attacking = false

func _on_player_knockback_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group(EnemyGroupName) && just_hit && !in_knockback_state:
		in_knockback_state = true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group(EnemyGroupName):
		enemy = null
