extends Node2D


enum Modes {
	DEACTIVATED,
	SINGLE_SHOT,
	CONTINUOUS_SHOOT,
}

const AIM_DIRECTIONS: Dictionary = {
	"up": Vector2.UP,
	"up_right": Vector2(1, -1),
	"right": Vector2.RIGHT,
	"down_right": Vector2(1, 1),
	"down": Vector2.DOWN,
	"down_left": Vector2(-1, 1),
	"left": Vector2.LEFT,
	"up_left": Vector2(-1, -1)
} 

@export var projectile: PackedScene
@export var shoot_delay: int
@export var shoot_on_start: bool = false
#@export var direction: Vector2 = AIM_DIRECTIONS["up"]
@export_enum("up", "up_right", "right", \
"down_right", "down", "down_left", \
"left", "up_left") var direction: String = "up"

var state: Modes = Modes.DEACTIVATED

func _ready() -> void:
	$Delay.wait_time = shoot_delay
	if shoot_on_start:
		activate(Modes.CONTINUOUS_SHOOT)
		

func activate(mode: Modes) -> void:
	state = mode
	shoot()

func shoot():
	match state:
		Modes.SINGLE_SHOT:
			create_bubble_instance()
			state = Modes.DEACTIVATED
		Modes.CONTINUOUS_SHOOT:
			create_bubble_instance()
			$Delay.start()

func create_bubble_instance():
	var bubble_shot = projectile.instantiate()
	add_child(bubble_shot)
	bubble_shot.global_position = $SpawnLocation.global_position
	bubble_shot.direction = AIM_DIRECTIONS[direction]

func _on_delay_timeout() -> void:
	shoot()
