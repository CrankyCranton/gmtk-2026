class_name Player extends CharacterBody3D


signal counters_changed(counters: Dictionary[String, int])
@warning_ignore("unused_signal")
signal counters_initialized(counters: Dictionary[String, int])
signal died

const MAX_TILT: float = deg_to_rad(90.0)
# If some guy does this many wall jumps, he deserves the honour of breaking the game.
const MAX_WALL_JUMPS: int = 9_999_999_999
const MAX_AIR_JUMPS: int = 1
const WALL_CAM_TILT := deg_to_rad(15.0)
const CAM_TILT_SPEED: float = 10.0
const FADE_TIME_START: int = 4

var counters: Dictionary = {}
# Only restores when the player hits the floor, not wall.
var wall_jumps_left: int = 0
var air_jumps_left: int = 0
var jump_force: float = 12.5
var wall_jump_force: float = 20.0
var gravity_scale: float = 2.0
var wallrun_gravity_scale: float = 0.01
var traction: float = 8.0
var air_traction: float = 2.0
var speed: float = 12.0
var wallrun_speed: float = 20.0
var mouse_sensitivity: float = 0.004 # Should probably add a setting menu for this eventually.
var just_hit_wall := false
var grapple_speed: float = 40.0
var grapple_range: float = 30.0
var grapple_point := Vector3.INF # INF means not grappling
var wallRunMomentum: float = 0.0 #Speed bonus that builds up as you wall run
var coyoteJump = true
var wallRunCoyoteJump = false
var wall_normal = null
var can_dash = true
var dash_speed: float = 40.0
var canWallStick = false
var grapple_tween: Tween
var fall_depth: float
var fall_fade_height: float = 20.0
var timer_fade_length: float
var fade_time_left := float(FADE_TIME_START)
var was_on_floor := false

@onready var wallStickTimer = $WalstickTimer
@onready var dash_timer = $DashCooldown
@onready var wall_run_coyote_timer = $WallRunCoyoteTimer
@onready var coyoteTimer = $CoyoteTimer
@onready var head: Marker3D = $Head
@onready var cursor: RayCast3D = %Cursor
@onready var rope_origin: Marker3D = %RopeOrigin
@onready var hand_r: Marker3D = %HandR
@onready var center: Marker3D = $Center
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fall_fade: ColorRect = $FallFade
@onready var grappling_extend: AudioStreamPlayer = $GrapplingExtend
@onready var grappling_retract: AudioStreamPlayer = $GrapplingRetract
@onready var grapple_hit: AudioStreamPlayer = $GrappleHit
@onready var hurt: AudioStreamPlayer = $Hurt
@onready var dash: AudioStreamPlayer = $Dash
@onready var footsteps_ground: AudioStreamPlayer = $FootstepsGround
@onready var footsteps_wall: AudioStreamPlayer = $FootstepsWall
@onready var landing: AudioStreamPlayer = $Landing
@onready var player_death: AudioStreamPlayer = $PlayerDeath
@onready var jump_from_ground: AudioStreamPlayer = $JumpFromGround
@onready var jump_from_mid_air: AudioStreamPlayer = $JumpFromMidAir
@onready var jump_from_wall: AudioStreamPlayer = $JumpFromWall


func _ready() -> void:
	cursor.target_position.z = -grapple_range
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if counters.has("time") and counters["time"] <= FADE_TIME_START:
		fade_time_left -= delta

	fall_fade.modulate.a = maxf(1.0 - fade_time_left / FADE_TIME_START,
			remap(global_position.y - fall_depth, 0.0, fall_fade_height, 1.0, 0.0))

	var input: Vector2 = Input.get_vector(&"left", &"right", &"forward", &"backward")
	if input != Vector2.ZERO and is_on_floor() and not is_on_wall():
		if not footsteps_ground.playing:
			footsteps_ground.play()
	else:
		footsteps_ground.stop()

	const WALLRUN_SOUND_SPEED: float = 10.0
	if input != Vector2.ZERO and is_on_wall() and Utils.vec3_to_2(velocity).length() > WALLRUN_SOUND_SPEED:
		if not footsteps_wall.playing:
			footsteps_wall.play()
	else:
		footsteps_wall.stop()

	var y: float = velocity.y
	var dash_speed_bonus = 1
	var current_speed: float = wallrun_speed * dash_speed_bonus if is_on_wall() else speed * dash_speed_bonus
	var current_traction: float = traction if is_on_floor() or is_on_wall() else air_traction

	var target_vel: Vector3 = Utils.vec2_to_3(input * current_speed * (1 + wallRunMomentum)).rotated(Vector3.UP, rotation.y)
	velocity = velocity.lerp(target_vel, current_traction * delta)
	velocity.y = y

	if dash_timer.time_left < 0.25 and dash_timer.time_left > 0:
		dash_speed_bonus = 2
	else:
		dash_speed_bonus = 1

	# NOTE: It's important that this is run before the if statements below,
	# because the is_on_floor() check will restore an extra jump immediatly after
	# if the player jumped from the floor.
	# Kind of a hack solution, so might need cleaning later.
	# But it makes it so that you won't get an extra mid-air jump if you fall off
	# a platform without jumping.
	if can_dash == true:
		if Input.is_action_just_pressed("dash") and has_counter_remaining("dashes"):
			dash.play()
			tick_counter("dashes")
			can_dash = false
			air_jumps_left = 1
			velocity += basis.z * -dash_speed
			dash_timer.start()
			$Head/Camera3D.damp = 2

#	if (Input.is_action_just_pressed(&"jump") and air_jumps_left > 0 and counters["jumps"] > 0
#			and not wallRunCoyoteJump == true):
#		velocity.y = jump_force
#		if coyoteJump == false:
#			air_jumps_left -= 1
#		coyoteJump = false
#		tick_counter("jumps")
	if coyoteJump == true:
		if Input.is_action_just_pressed(&"jump"):
			velocity.y = jump_force
			jump_from_ground.play()
	elif air_jumps_left > 0 and has_counter_remaining("air_jumps") and not wallRunCoyoteJump == true:
		if Input.is_action_just_pressed(&"jump"):
			jump_from_mid_air.play()
			velocity.y = jump_force
			coyoteJump = false
			tick_counter("air_jumps")
			air_jumps_left -= 1

	if is_on_floor():
		if not was_on_floor:
			landing.play(0.5)
		coyoteJump = true
		wall_jumps_left = MAX_WALL_JUMPS
		air_jumps_left = MAX_AIR_JUMPS
		just_hit_wall = false
	else:
		if not coyoteTimer.time_left > 0.0:
			coyoteTimer.start()
	var target_tilt: float = 0.0

	if not wall_normal == null && canWallStick == true:
		velocity += wall_normal * -2

	if is_on_wall():
		canWallStick = true
		const WALL_PUSHOFF_WEIGHT: float = 0.6
		wall_normal = Vector3.UP.slerp(get_wall_normal(), WALL_PUSHOFF_WEIGHT
					)
		wallRunCoyoteJump = true
#stores the walls normal
		velocity.y *= 0.2 # slow down the players gravity when on al wall
		if velocity.length() > 5:
			wallRunMomentum = clampf(wallRunMomentum + (0.35 * delta / (1+(wallRunMomentum/10))),0,3) # wallrun momentum builds up slower the more of it you have
		target_tilt = -get_wall_normal().dot(global_basis.x) * WALL_CAM_TILT
		if not just_hit_wall:
			#velocity.y = 0.0 # Stop gravity when you hit a wall.
			just_hit_wall = true
	else:
		if not wall_run_coyote_timer.time_left > 0.0:
			wall_run_coyote_timer.start()
		if not wallStickTimer.time_left > 0.0:
			wallStickTimer.start()
		just_hit_wall = false
		wallRunMomentum = clampf(wallRunMomentum -0.2 * delta,0,3)

	if (Input.is_action_just_pressed(&"jump") and wall_jumps_left > 0 and wallRunCoyoteJump == true
			and has_counter_remaining("wall_jumps")):
		jump_from_wall.play()
		velocity += wall_normal * wall_jump_force
		wall_jumps_left -= 1
		air_jumps_left = 1
		tick_counter("wall_jumps")
		wallRunCoyoteJump = false

	if cursor.is_colliding():
		$Crosshair.scale = Vector2(2,2)
	else:
		$Crosshair.scale = Vector2(1,1)

	var current_gravity_scale: float = gravity_scale
	if just_hit_wall:
		current_gravity_scale *= wallrun_gravity_scale
	velocity += get_gravity() * current_gravity_scale * delta

	# Might could switch to tweens later.
	head.rotation.z = lerpf(head.rotation.z, target_tilt, CAM_TILT_SPEED * delta)

	if grapple_point != Vector3.INF:
		velocity += global_position.direction_to(grapple_point) * grapple_speed * delta
		rope_origin.look_at(grapple_point)
		rope_origin.scale.z = rope_origin.global_position.distance_to(grapple_point) - 0.2

	was_on_floor = is_on_floor()
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_vel: Vector2 = event.screen_relative * mouse_sensitivity
		head.rotation.x -= mouse_vel.y
		head.rotation.x = clampf(head.rotation.x, -MAX_TILT, MAX_TILT)
		rotation.y -= mouse_vel.x

	if event.is_action_pressed(&"grappling_hook") and has_counter_remaining("grappling_hooks"):
		grappling_extend.play()
		if cursor.is_colliding():
			grapple_hit.play()
			grapple_point = (cursor.get_collision_point() if cursor.is_colliding()
					else cursor.to_global(cursor.target_position))
			tick_counter("grappling_hooks")
			if grapple_tween:
				grapple_tween.kill()
				grapple_tween = null
		else:
				grapple_tween = create_tween()
				grapple_tween.tween_property(rope_origin, ^"scale:z",
						cursor.target_position.length(), 0.3)
				recoil_hook()
	if event.is_action_released(&"grappling_hook"):
		grapple_point = Vector3.INF
		if grapple_tween != null:
			grapple_tween.kill()
		grapple_tween = create_tween()
		recoil_hook()

	if event.is_action_pressed(&"dagger") and has_counter_remaining("ammo"):
		const BULLET: PackedScene = preload("res://player/dagger/dagger.tscn")
		var bullet: Dagger = BULLET.instantiate()
		bullet.hit.connect(_on_dagger_hit)
		add_sibling.call_deferred(bullet)
		await bullet.ready
		bullet.global_transform = hand_r.global_transform
		tick_counter("ammo")

	if event.is_action_pressed(&"ui_cancel"):
		# Might want to add a pause screen.
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED \
				if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE


func recoil_hook() -> void:
	grappling_retract.play()
	grapple_tween.tween_property(rope_origin, ^"scale:z", 0.001, 0.3)
	grapple_tween.tween_property(rope_origin, ^"rotation", Vector3.ZERO, 0.1)
	await grapple_tween.finished
	grapple_tween = null


func tick_counter(counter: String) -> void:
	if counter == "health":
		hurt.play()
		animation_player.play(&"hit")
	if (not counters.has(counter)) or counters[counter] <= 0:
		return
	counters[counter] -= 1
	counters_changed.emit(counters.duplicate())
	if (counters.has("time") and counters["time"] == 0) \
			or (counters.has("health") and counters["health"] == 0):
		die()


func die() -> void:
	player_death.play()
	player_death.reparent(get_tree().root)
	died.emit()


func has_counter_remaining(counter: String) -> bool:
	return (not counters.has(counter)) or counters[counter] != 0


func _on_timer_tick_timeout() -> void:
	tick_counter("time")


func _on_coyote_timer_timeout() -> void:
	coyoteJump = false


func _on_wall_run_coyote_timer_timeout() -> void:
	wallRunCoyoteJump = false


func _on_dash_cooldown_timeout() -> void:
	can_dash = true
	$Head/Camera3D.damp = 1


func _on_walstick_timer_timeout() -> void:
	canWallStick = false


func _on_dagger_hit() -> void:
	tick_counter("enemies")
