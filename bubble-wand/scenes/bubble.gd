extends CharacterBody2D

@export var SPEED = 600.0
const PLAYER_IMMUNITY_TIME = 0.15

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
	var current_speed=SPEED
	if immunity_timer > 0:
		current_speed += 100
		immunity_timer -= delta
		if immunity_timer <= 0:
			$Area2D/CollisionShape2D.disabled = false

	velocity = direction * current_speed
	var collision = move_and_collide(velocity * delta)

	if collision:
		var normal = collision.get_normal()

		# Bubble hit a wall or other object
		direction = direction.bounce(normal)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Player collision rectangle
		var player_collision = body.get_node("CollisionShape2D")
		var player_shape = player_collision.shape

		var player_half_width = player_shape.size.x * player_collision.scale.x / 2.0
		var player_half_height = player_shape.size.y * player_collision.scale.y / 2.0

		var player_left = body.global_position.x - player_half_width
		var player_right = body.global_position.x + player_half_width
		var player_top = body.global_position.y - player_half_height
		var player_bottom = body.global_position.y + player_half_height

		# Bubble collision rectangle
		var bubble_shape = $Area2D/CollisionShape2D.shape
		var bubble_half_width = bubble_shape.size.x / 2.0
		var bubble_half_height = bubble_shape.size.y / 2.0

		var bubble_left = global_position.x - bubble_half_width
		var bubble_right = global_position.x + bubble_half_width
		var bubble_top = global_position.y - bubble_half_height
		var bubble_bottom = global_position.y + bubble_half_height

		# Calculate how much the rectangles overlap
		var overlap_x = min(player_right, bubble_right) - max(player_left, bubble_left)
		var overlap_y = min(player_bottom, bubble_bottom) - max(player_top, bubble_top)

		# Smaller overlap tells us which side was hit
		if overlap_y < overlap_x:
			if body.global_position.y < global_position.y:
				# Player hit the top
				print("hit top")
				body.bounce_on_bubble()
			else:
				# Player hit the bottom
				print("hit bottom")
				body.velocity.y = 100
		else:
			if body.global_position.x < global_position.x:
				# Player hit the left side
				print("hit left")
				body.velocity.x = velocity.x / 2 - 200
			else:
				# Player hit the right side
				print("hit right")
				body.velocity.x = velocity.x / 2 + 200

		queue_free()
