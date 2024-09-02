extends CharacterBody3D

signal fell

const WALK_SPEED = 4.0
const SPRINT_SPEED = 7.0
const CROUCH_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
const DEF_FOV = 75
const SPRINT_FOV = 75
const CROUCH_HEAD = Vector3(.0,-.5,.0)
const DEFAULT_HEAD = Vector3(.0,.0,.0)

var speed: float
var direction := Vector3.ZERO
var input_dir := Vector2.ZERO

enum {WALK, SPRINT, CROUCH}
var inputmotion = false
var falling_from_jump = false
var state = WALK
var head_pos = DEFAULT_HEAD

var t = false
var boing = 0

var stamina: int = 1

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var player = $CollisionShape3D
@onready var animator = $AnimationTree

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    #animator.speed_scale *= 0
    #animator.play("head_bob")

func _unhandled_input(event):
    if event is InputEventMouseMotion:
        head.rotate_y(-event.relative.x * SENSITIVITY)
        camera.rotate_x(-event.relative.y * SENSITIVITY)

func _physics_process(delta: float) -> void:
    if t and boing < 1:
        boing = lerpf(boing,2,delta*2)
    else:
        t = false
        boing = lerpf(boing,0,delta)
    
    if Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) < -0.2 or Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) > 0.2:
        head.rotate_y(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_X) * SENSITIVITY * 15)
    if Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) < -0.2 or Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) > 0.2:
        camera.rotate_x(-Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y) * SENSITIVITY * 15)
    camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
    
    input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if Input.is_action_pressed("crouch"):
        state = CROUCH
    elif Input.is_action_pressed("sprint"):
        state = SPRINT
    else:
        state = WALK
        
    match state:
        WALK:
            speed = WALK_SPEED
            head_pos = DEFAULT_HEAD
            # animator.speed_scale = 8
        SPRINT:
            speed = SPRINT_SPEED
            head_pos = DEFAULT_HEAD
            # animator.speed_scale = 13
        CROUCH:
            speed = CROUCH_SPEED
            head_pos = CROUCH_HEAD
            # animator.speed_scale = 4

    if not is_on_floor():
        velocity += get_gravity() * delta


    if Input.is_action_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
        falling_from_jump = false

    head.position = lerp(head.position, head_pos, delta*15)
    
    if not is_on_floor(): pass
        # animator.speed_scale *= 0.4
        
    if direction:
        pass
        # animator.speed_scale *= 1
    else:
        pass
        # animator.speed_scale *= 0
    
    if is_on_floor():
        if direction:
            velocity.x = direction.x * speed
            velocity.z = direction.z * speed
        else:
            velocity.x = move_toward(velocity.x, 0, speed/12)
            velocity.z = move_toward(velocity.z, 0, speed/12)
    else:
        velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
        velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)

    move_and_slide()
    handle_trees()

    if is_on_floor():
        if not falling_from_jump:
            fell.emit()
        falling_from_jump = true

func handle_trees():
    animator["parameters/Blend2/blend_amount"] = boing

func _on_fell() -> void:
    t = true
    # playback.
    # playback.travel("boing")
