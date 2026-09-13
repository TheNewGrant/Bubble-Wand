extends CharacterBody2D

const MIN_SPEED = 200.0
const MAX_SPEED = 400.0
const ACCELERATION = 400.0
const JUMP_VELOCITY = -500.0
const JUMP_CUTOFF = -250.0

func _physics_process(delta: float) -> void:
	# Add gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
# Cut the jump short when the button is released.
	if Input.is_action_just_released("jump") and velocity.y < JUMP_CUTOFF:
		velocity.y = JUMP_CUTOFF
	
	# Get input direction.
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		if sign(velocity.x) != sign(direction):
			velocity.x = direction * MIN_SPEED
		else:
			velocity.x = move_toward(velocity.x, direction * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, MAX_SPEED * 2 * delta)

	print(velocity.x)
	move_and_slide()
