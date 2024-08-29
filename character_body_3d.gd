extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const CROUCH_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

const BOB_FREQ = 2
const BOB_AMP = 0.08
var t_bob = 0.0


var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var player = $CollisionShape3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)

func _physics_process(delta: float) -> void:
	
	if Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) < -0.2 or Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) > 0.2:
		head.rotate_y(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * SENSITIVITY * 15)
	if Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) < -0.2 or Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) > 0.2:
		camera.rotate_x(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) * SENSITIVITY * 15)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	
	
	if Input.is_action_pressed("L-Shift"):
		speed = SPRINT_SPEED
		player.scale.y = 1
	else:
		if Input.is_action_pressed("crouch"):
			speed = CROUCH_SPEED
			player.scale.y = 0.5
		else:
			speed = WALK_SPEED
			player.scale.y = 1
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time *BOB_FREQ / 2) *BOB_AMP
	return pos
