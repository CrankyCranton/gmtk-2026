extends Camera3D
@onready var body = $"../.."
var speedLineDensity = 0.0
var baseFov = 75.0
var fovScale = 1

func _physics_process(delta: float) -> void:
	get_node("SpeedLines").get_child(0).material.set_shader_parameter("line_density",clampf(sqrt(Vector2(body.velocity.x,body.velocity.z).length() - 20.0)/7.5,0.0,1.0))
	var targetFov = baseFov + fovScale * clampf(pow(body.velocity.length(),0.8) - 0.25 ,1.0,30.0)
	fov = lerp(fov,targetFov, delta * 3)
