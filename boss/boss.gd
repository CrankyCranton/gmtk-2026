class_name Boss extends Area3D


signal annoyed
signal defeated

var health: int = 5

@onready var annoyance_bar: TextureProgressBar = $AnnoyanceBar


func _ready() -> void:
	annoyance_bar.max_value = health
	annoyance_bar.value = health


func _on_body_entered(_body: Node3D) -> void:
	print("U won!")
	health -= 1
	annoyance_bar.value = health
	annoyed.emit()
	if health <= 0:
		defeated.emit()
