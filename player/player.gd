class_name Player extends CharacterBody3D


signal counters_changed(counters: Dictionary[String, int])
signal counters_initialized(counters: Dictionary[String, int])

const MAX_TILT: float = deg_to_rad(90.0)
const MAX_WALL_JUMPS: int = 3
const MAX_AIR_JUMPS: int = 1
const WALL_CAM_TILT := deg_to_rad(15.0)
const CAM_TILT_SPEED: float = 10.0

var counters: Dictionary[String, int] = {
	"health": 3,
	"ammo": 5,
	"jumps": 10,
	"wall_jumps": 15,
	"grappling_hooks": 5,
	"time": 30,
}
# Only restores when the player hits the floor, not wall.
var wall_jumps_left: int = 0
var air_jumps_left: int = 0
var jump_force: float = 10.0
var wall_jump_force: float = 20.0
var gravity_scale: float = 2.0
var wallrun_gravity_scale: float = 0.05
var traction: float = 5.0
var air_traction: float = 2.0
var speed: float = 8.0
var wallrun_speed: float = 20.0
var mouse_sensitivity: float = 0.004 # Should probably add a setting menu for this eventually.
var just_hit_wall := false
var grapple_speed: float = 30.0
var grapple_point := Vector3.INF # INF means not grappling

@onready var head: Marker3D = $Head
@onready var cursor: ShapeCast3D = %Cursor
@onready var rope_origin: Marker3D = %RopeOrigin


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	counters_initialized.emit(counters.duplicate())


func _physics_process(delta: float) -> void:
	var input: Vector2 = Input.get_vector(&"left", &"right", &"forward", &"backward")
	var y: float = velocity.y
	var current_speed: float = wallrun_speed if is_on_wall() else speed
	var current_traction: float = traction if is_on_floor() or is_on_wall() else air_traction

	var target_vel: Vector3 = Utils.vec2_to_3(input * current_speed).rotated(Vector3.UP, rotation.y)
	velocity = velocity.lerp(target_vel, current_traction * delta)
	velocity.y = y

	# NOTE: It's important that this is run before the if statements below,
	# because the is_on_floor() check will restore an extra jump immediatly after
	# if the player jumped from the floor.
	# Kind of a hack solution, so might need cleaning later.
	# But it makes it so that you won't get an extra mid-air jump if you fall off
	# a platform without jumping.
	if (Input.is_action_just_pressed(&"jump") and air_jumps_left > 0 and counters["jumps"] > 0
			and not is_on_wall()):
		velocity.y = jump_force
		air_jumps_left -= 1
		tick_counter("jumps")

	if is_on_floor():
		wall_jumps_left = MAX_WALL_JUMPS
		air_jumps_left = MAX_AIR_JUMPS
		just_hit_wall = false
	#else:
	var target_tilt: float = 0.0
	if is_on_wall():
		target_tilt = -get_wall_normal().dot(global_basis.x) * WALL_CAM_TILT
		if not just_hit_wall:
			velocity.y = 0.0 # Stop gravity when you hit a wall.
			just_hit_wall = true

		if (Input.is_action_just_pressed(&"jump") and wall_jumps_left > 0
				and counters["wall_jumps"] > 0):
			const WALL_PUSHOFF_WEIGHT: float = 0.6
			velocity = Vector3.UP.slerp(get_wall_normal(), WALL_PUSHOFF_WEIGHT
					) * wall_jump_force
			wall_jumps_left -= 1
			tick_counter("wall_jumps")
	else:
		just_hit_wall = false

	var current_gravity_scale: float = gravity_scale
	if just_hit_wall:
		current_gravity_scale *= wallrun_gravity_scale
	velocity += get_gravity() * current_gravity_scale * delta

	# Might could switch to tweens later.
	head.rotation.z = lerpf(head.rotation.z, target_tilt, CAM_TILT_SPEED * delta)

	if grapple_point != Vector3.INF:
		velocity += global_position.direction_to(grapple_point) * grapple_speed * delta
		rope_origin.look_at(grapple_point)
		rope_origin.scale.z = rope_origin.global_position.distance_to(grapple_point)
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_vel: Vector2 = event.screen_relative * mouse_sensitivity
		head.rotation.x -= mouse_vel.y
		head.rotation.x = clampf(head.rotation.x, -MAX_TILT, MAX_TILT)
		rotation.y -= mouse_vel.x

	if (event.is_action_pressed(&"grappling_hook") and cursor.is_colliding()
			and counters["grappling_hooks"] > 0):
		grapple_point = (cursor.get_collision_point(0) if cursor.is_colliding()
				else cursor.to_global(cursor.target_position))
		tick_counter("grappling_hooks")
	if event.is_action_released(&"grappling_hook"):
		rope_origin.scale.z = 0.001
		grapple_point = Vector3.INF


func tick_counter(counter: String) -> void:
	counters[counter] -= 1
	counters_changed.emit(counters.duplicate())


func _on_timer_tick_timeout() -> void:
	tick_counter("time")
	if counters["time"] <= 0:
		# Copied from fall_zone.gd. Later we'll need to find a way to link them together.
		print("U looze")
		get_tree().paused = true
		await get_tree().create_timer(1.5).timeout
		get_tree().paused = false
		get_tree().reload_current_scene()
