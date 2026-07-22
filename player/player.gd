class_name Player extends CharacterBody3D


const MAX_TILT: float = deg_to_rad(90.0)
const MAX_WALL_JUMPS: int = 3
const MAX_AIR_JUMPS: int = 1
const WALL_CAM_TILT := deg_to_rad(15.0)
const CAM_TILT_SPEED: float = 10.0

# Only restores when the player hits the floor, not wall.
var wall_jumps_left: int = 0
var air_jumps_left: int = 0
var jump_force: float = 7.5
var wall_jump_force: float = 20.0
var gravity_scale: float = 2.0
var wallrun_gravity_scale: float = 0.1
var traction: float = 16.0 # Not used yet.
var air_traction: float = 2.0
var speed: float = 6.0
var wallrun_speed: float = 9.0
var mouse_sensitivity: float = 0.004 # Should probably add a setting menu for this eventually.
var was_on_wall := false

@onready var head: Marker3D = $Head
@onready var wall_detector: Area3D = $WallDetector


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	var on_wall: bool = wall_detector.get_overlapping_bodies().size() > 0

	var input: Vector2 = Input.get_vector(&"left", &"right", &"forward", &"backward")
	var y: float = velocity.y
	var current_speed: float = speed if is_on_floor() else wallrun_speed
	var current_traction: float = traction if is_on_floor() or on_wall else air_traction

	var target_vel: Vector3 = Utils.vec2_to_3(input * current_speed).rotated(Vector3.UP, rotation.y)
	velocity = velocity.lerp(target_vel, current_traction * delta)
	velocity.y = y

	# NOTE: It's important that this is run before the if statements below.
	if (Input.is_action_just_pressed(&"jump") and air_jumps_left > 0
			and (is_on_floor() or not on_wall)):
		velocity.y = jump_force
		air_jumps_left -= 1

	if is_on_floor():
		wall_jumps_left = MAX_WALL_JUMPS
		air_jumps_left = MAX_AIR_JUMPS
	else:
		var current_gravity_scale: float = gravity_scale
		if on_wall:
			if not was_on_wall:
				velocity.y = 0.0 # Stop gravity when you hit a wall.
			current_gravity_scale *= wallrun_gravity_scale

			if Input.is_action_just_pressed(&"jump") and wall_jumps_left > 0:
				const WALL_PUSHOFF_WEIGHT: float = 0.5
				velocity = Vector3.UP.slerp(get_wall_normal(), WALL_PUSHOFF_WEIGHT
						) * wall_jump_force
				wall_jumps_left -= 1

		velocity += get_gravity() * current_gravity_scale * delta

	var target_tilt: float = 0.0
	# TODO: Make a way to get the normal if it's just touching wall_detector, and not the actual wall.
	if is_on_wall():
		target_tilt = -get_wall_normal().dot(global_basis.x) * WALL_CAM_TILT
	# Might could switch to tweens later.
	head.rotation.z = lerpf(head.rotation.z, target_tilt, CAM_TILT_SPEED * delta)

	move_and_slide()
	was_on_wall = on_wall


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_vel: Vector2 = event.screen_relative * mouse_sensitivity
		head.rotation.x -= mouse_vel.y
		head.rotation.x = clampf(head.rotation.x, -MAX_TILT, MAX_TILT)
		rotation.y -= mouse_vel.x
