extends CharacterBody2D
@export var bubble_scene: PackedScene
const MAX_SPEED = 400.0
const GROUND_ACCELERATION = 2200.0
const AIR_ACCELERATION = 1200.0
const GROUND_FRICTION = 1000.0
const AIR_FRICTION = 200.0
@export var GRAVITY: int
const JUMP_VELOCITY = -500.0
const JUMP_CUTOFF = -200.0

const JUMP_BUFFER_TIME = 0.15
const COYOTE_TIME = 0.1

var jump_buffer_timer = 0.0
var coyote_timer = 0.0


func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

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
	if Input.is_action_just_pressed("Shoot"):
		shoot_bubble()

	move_and_slide()
	
func shoot_bubble() -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Don't shoot if no direction is being held
	if direction == Vector2.ZERO:
		return

	var bubble = bubble_scene.instantiate()

	bubble.global_position = global_position
	bubble.direction = direction

	get_parent().add_child(bubble)
