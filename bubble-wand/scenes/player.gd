extends CharacterBody2D
@export var bubble_scene: PackedScene
const MAX_SPEED = 500.0
const GROUND_ACCELERATION = 2200.0
const AIR_ACCELERATION = 1400.0
const GROUND_FRICTION = 1000.0
const AIR_FRICTION = 200.0
@export var GRAVITY: int
const JUMP_VELOCITY = -800.0
const JUMP_CUTOFF = -200.0

const JUMP_BUFFER_TIME = 0.15
const COYOTE_TIME = 0.1

var jump_buffer_timer = 0.0
var coyote_timer = 0.0

const BUBBLE_JUMP_GRACE_TIME = 0.15
var bubble_jump_grace_timer = 0.0
var bubble_jump_active = false
const SHOOT_COOLDOWN = 0.5
var shoot_cooldown_timer = 0.0

var facing_direction = 1

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		if velocity.y > 700:
			velocity.y = 700
		if Input.is_action_pressed("ui_down") and velocity.y > 0:
			velocity.y += GRAVITY * 1.2 * delta
	if bubble_jump_grace_timer > 0:
		bubble_jump_grace_timer -= delta

		if Input.is_action_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			bubble_jump_grace_timer = 0
			bubble_jump_active = false

		elif bubble_jump_grace_timer <= 0:
			velocity.y = JUMP_CUTOFF
			bubble_jump_active = false
	# Coyote time
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	# Jump
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0

	# Cut the jump short when the button is released
	if Input.is_action_just_released("jump") and velocity.y < JUMP_CUTOFF:
		velocity.y = JUMP_CUTOFF
	# Get input direction.
	var direction := Input.get_axis("left", "right")
	if direction == 0:
		direction = Input.get_axis("ui_left", "ui_right")


	if direction != 0:
		facing_direction = sign(direction)
		if direction == 0:
			direction = Input.get_axis("ui_left", "ui_right")
	
	if direction != 0:
		var acceleration = GROUND_ACCELERATION if is_on_floor() else AIR_ACCELERATION

		# Accelerate toward the desired direction
		velocity.x = move_toward(
			velocity.x,
			direction * MAX_SPEED,
			acceleration * delta
		)
	else:
		# Slow down when there is no input
		var friction = GROUND_FRICTION if is_on_floor() else AIR_FRICTION

		velocity.x = move_toward(
			velocity.x,
			0,
			friction * delta
		)
	if shoot_cooldown_timer > 0:
		shoot_cooldown_timer -= delta
	if Input.is_action_just_pressed("Shoot"):
		shoot_bubble()

	move_and_slide()
	
func shoot_bubble() -> void:
	#cooldown
	if shoot_cooldown_timer > 0:
		return
	shoot_cooldown_timer = SHOOT_COOLDOWN

	var direction := Input.get_vector("left", "right", "ui_up", "ui_down")
	if direction.length() == 0:
		direction = Vector2(facing_direction, 0)

	var angle = direction.angle()
	var snapped_angle = round(angle / (PI / 4.0)) * (PI / 4.0)
	direction = Vector2.from_angle(snapped_angle)
	#player gets a slight recoil
	velocity -= direction * 200
	print("Shoot direction: ", direction)
	

	# Snap to one of 8 directions
	for bubble in get_tree().get_nodes_in_group("bubble"):
		bubble.queue_free()
	var bubble = bubble_scene.instantiate()

	bubble.global_position = global_position + direction * 30.0
	bubble.direction = direction

	get_parent().add_child(bubble)
	
func bounce_on_bubble() -> void:
	velocity.y = JUMP_VELOCITY
	bubble_jump_grace_timer = BUBBLE_JUMP_GRACE_TIME
	bubble_jump_active = true
