extends CharacterBody2D

const SPEED = 600.0
const PLAYER_IMMUNITY_TIME = 0.2

var direction := Vector2.ZERO
var immunity_timer := PLAYER_IMMUNITY_TIME


func _ready() -> void:
	add_to_group("bubble")
	#area2dcollision is what's detected by the player
	#this makes it so you don't spawn in the bubble immediately
	$Area2D/CollisionShape2D.disabled = true


func _physics_process(delta: float) -> void:
	# Give the player a short period where the bubble cannot collide
	# with them after being spawned.
	if immunity_timer > 0:
		immunity_timer -= delta
		
		if immunity_timer <= 0:
			$Area2D/CollisionShape2D.disabled = false

	velocity = direction * SPEED
	var collision = move_and_collide(velocity * delta)

	if collision:
		var normal = collision.get_normal()

		# Bubble hit a wall or other object
		direction = direction.bounce(normal)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var collision_shape = body.get_node("CollisionShape2D")
		var half_width = collision_shape.shape.size.x * collision_shape.scale.x / 2.0
		var half_height = collision_shape.shape.size.y * collision_shape.scale.y / 2.0
		var player_left = body.global_position.x - half_width
		var player_right = body.global_position.x + half_width
		var player_top = body.global_position.y - half_height
		var player_bottom = body.global_position.y + half_height

		# Find the closest point on the player's collision box
		# to the center of the bubble.
		var closest_x = clamp(global_position.x, player_left, player_right)
		var closest_y = clamp(global_position.y, player_top, player_bottom)

		var difference = Vector2(
			closest_x - global_position.x,
			closest_y - global_position.y
		)

		# Determine which part of the bubble was touched
		if abs(difference.y) > abs(difference.x):
			if difference.y < 0:
				# Top of bubble
				print("hit top")
				body.bounce_on_bubble()
			else:
				# Bottom of bubble
				print("hit bottom")
				body.velocity.y += 600
		else:
			# Side of bubble
			print("hit side")

			if body.global_position.x < global_position.x:
				body.velocity.x -= 600
			else:
				body.velocity.x += 600
		queue_free()
