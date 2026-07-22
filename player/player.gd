class_name Player extends CharacterBody3D


const MAX_TILT: float = deg_to_rad(90.0)

var jump_force: float = 5.0
var gravity_scale: float = 1.0
var traction: float = 20.0 # Not used yet.
# Not used yet. We'll need to think of how we want to translate input into velocity.
var target_vel := Vector2()
var speed: float = 6.0
var mouse_sensitivity: float = 0.004 # Should probably add a setting menu for this eventually.

@onready var head: Marker3D = $Head


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	var input: Vector2 = Input.get_vector(&"left", &"right", &"forward", &"backward")
	var y: float = velocity.y
	velocity = Utils.vec2_to_3(input * speed).rotated(Vector3.UP, rotation.y)
	velocity.y = y
	if not is_on_floor():
		velocity += get_gravity() * gravity_scale * delta
	elif Input.is_action_just_pressed(&"jump"):
		velocity.y = jump_force

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_vel: Vector2 = event.screen_relative * mouse_sensitivity
		head.rotation.x -= mouse_vel.y
		head.rotation.x = clampf(head.rotation.x, -MAX_TILT, MAX_TILT)
		rotation.y -= mouse_vel.x
