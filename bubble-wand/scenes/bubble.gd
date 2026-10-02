extends CharacterBody2D

const SPEED = 500.0
const PLAYER_IMMUNITY_TIME = 0.1

var direction := Vector2.ZERO
var immunity_timer := PLAYER_IMMUNITY_TIME


func _ready() -> void:
	add_to_group("bubble")
	$CollisionShape2D.disabled = true


func _physics_process(delta: float) -> void:
	# Give the player a short period where the bubble cannot collide
	# with them after being spawned.
	if immunity_timer > 0:
		immunity_timer -= delta
		
		if immunity_timer <= 0:
			$CollisionShape2D.disabled = false

	velocity = direction * SPEED
	var collision = move_and_collide(velocity * delta)

	if collision:
		var body = collision.get_collider()
		var normal = collision.get_normal()

		if body.name == "Player":
			body.bounce_on_bubble()
			queue_free()

		# Bubble hit a wall or other object
		else:
			direction = direction.bounce(normal)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.bounce_on_bubble()
		queue_free()
