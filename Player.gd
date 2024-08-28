extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

#bob vars
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

#sword vars
var melee_damage = 50

#fov vars
const BASE_FOV = 80.0
const FOV_CHANGE = 1.5

#slide vars
var fall_distance = 0
var slide_speed = 0
var can_slide = false
var sliding = false
var falling = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var slide_check = $Slide_Check
@onready var melee_anim = $AnimationPlayer
@onready var hitbox = $Head/Camera3D/Hitbox

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
    if event is InputEventMouseMotion:
        head.rotate_y(-event.relative.x * SENSITIVITY)
        camera.rotate_x(-event.relative.y * SENSITIVITY)
        camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

var hitflag = false

func melee():
    if Input.is_action_just_pressed("fire"):
        hitflag = true
        if not melee_anim.is_playing():
            melee_anim.play("Attack1")
            melee_anim.queue("return")
    if melee_anim.current_animation == "Attack1":
        if hitflag:
            for body in hitbox.get_overlapping_bodies():
                print (body)
                pass
                if body.is_in_group("Enemy"):
                    pass
                    body.health -= melee_damage
    hitflag = false

func _physics_process(delta):
    
    melee()
    
    # Add the gravity.
    if not is_on_floor():
        velocity.y -= gravity * delta
        falling = true
    else:
        falling = false
    
    if falling and is_on_floor() and sliding:
        slide_speed += fall_distance / 10.0
    fall_distance = -gravity

    # Handle jump.
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
        if sliding:
            slide_speed -= 1
    
    #handle sprint
    if Input.is_action_pressed("sprint"):
        speed = SPRINT_SPEED
    else:
        speed = WALK_SPEED

    if Input.is_action_just_pressed("slide") and speed > 3:
        can_slide = true
    
    if Input.is_action_pressed("slide") and is_on_floor() and Input.is_action_pressed("up") and can_slide:
        slide()
    
    if Input.is_action_just_released("slide"):
        can_slide = false
        sliding = false
    
    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir = Input.get_vector("left", "right", "up", "down")
    var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if is_on_floor():
        if direction:
            velocity.x = direction.x * speed
            velocity.z = direction.z * speed
        else:
            velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.5)
            velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.5)
    else:
        velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
        velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
        
    # head bob
    t_bob += delta * velocity.length() * float(is_on_floor())
    camera.transform.origin = _headbob(t_bob)
    
    #FOV
    var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
    var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
    camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

    move_and_slide()


func _headbob(time) -> Vector3:
    var pos = Vector3.ZERO
    pos.y = sin(time * BOB_FREQ) * BOB_AMP
    pos.x = cos(time *BOB_FREQ / 2) *BOB_AMP
    return pos

func slide():
    if not sliding:
        if slide_check.is_colliding() or get_floor_angle() < 0.2:
            slide_speed = 5
            slide_speed += fall_distance / 10
        else:
            slide_speed = 2
    sliding = true
    
    if slide_check.is_colliding():
        slide_speed += get_floor_angle() / 10
    else:
        slide_speed -= (get_floor_angle() / 5) + 0.03
    
    if slide_speed > 10:
        slide_speed = 10
    
    if slide_speed < 0:
        can_slide = false
        sliding = false
    
    speed = slide_speed
