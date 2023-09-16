extends CharacterBody2D


const SPEED = 800.0
const GRAVITY_SCALE = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * GRAVITY_SCALE
var direction  : Vector2

func _ready():
	direction = Vector2(1, 0).rotated(rotation)
	velocity = SPEED * direction

func _physics_process(delta):

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	move_and_slide()
