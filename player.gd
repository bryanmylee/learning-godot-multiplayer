extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var syncPos := Vector2(0,0)
var syncRot := 0

# @export exposes an interface to be injected into this script via the Scene Editor.
@export var bullet : PackedScene

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	$GunRotation.look_at(get_viewport().get_mouse_position())
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	syncPos = global_position
	syncRot = rotation_degrees

	if Input.is_action_just_pressed("fire"):
		var b := bullet.instantiate()
		b.global_position = $GunRotation/BulletSpawn.global_position
		b.rotation_degrees = $GunRotation.rotation_degrees
		get_tree().root.add_child(b)

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
#
	move_and_slide()
 
