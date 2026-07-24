class_name Dagger extends Area3D
# TODO: Make daggers delete after a certain period of time,
# or when they drop bellow a certain distance. (same for enemy bullets)


var speed: float = 40.0
var gravity_scale: float = 0.15
var velocity := Vector3()


func _physics_process(delta: float) -> void:
	global_position += -global_basis.z * speed * delta
	velocity += ProjectSettings.get_setting("physics/3d/default_gravity_vector") * gravity_scale
	global_position += velocity * delta


func _on_body_entered(_body: Node3D) -> void:
	queue_free()


func _on_area_entered(area: Area3D) -> void:
	area.queue_free()
	queue_free()
