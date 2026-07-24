class_name EnemyBullet extends Area3D
# TODO: Inherit from parent scene to merge behavior with dagger.tscn


var speed: float = 40.0
var gravity_scale: float = 1.0


func _physics_process(delta: float) -> void:
	global_position += -global_basis.z * speed * delta
	global_position += ProjectSettings.get_setting("physics/3d/default_gravity_vector") \
			* gravity_scale * delta


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.tick_counter("health")
	queue_free()
