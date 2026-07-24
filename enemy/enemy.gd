class_name Enemy extends Area3D


var player: Player = null

@onready var shoot_timer: Timer = $ShootTimer
@onready var barrel: Marker3D = $Barrel


func _physics_process(_delta: float) -> void:
	if player:
		var flat_vec: Vector2 = Utils.vec3_to_2(
				global_position.direction_to(player.global_position))
		flat_vec.x *= -1 # Flipped because 3D and 2D rotate in opposite directions.
		# Rotated because X is 0 rotation in 2D
		var angle: float = flat_vec.angle() + deg_to_rad(90.0)
		rotation.y = angle


func _on_detection_zone_body_entered(body: Node3D) -> void:
	player = body
	shoot_timer.start()


func _on_detection_zone_body_exited(_body: Node3D) -> void:
	player = null
	shoot_timer.stop()


# Merge with bullet code in player.gd
func _on_shoot_timer_timeout() -> void:
	const BULLET: PackedScene = preload("res://enemy/enemy_bullet/enemy_bullet.tscn")
	var bullet: EnemyBullet = BULLET.instantiate()
	add_sibling.call_deferred(bullet)
	await bullet.ready
	bullet.global_position = barrel.global_position
	bullet.global_basis = Basis.looking_at(barrel.global_position.direction_to(
			player.center.global_position))
