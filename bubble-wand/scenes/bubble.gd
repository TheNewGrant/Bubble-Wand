extends CharacterBody2D

const SPEED = 500.0

var direction := Vector2.ZERO


func _physics_process(delta: float) -> void:
	velocity = direction * SPEED
	move_and_slide()
