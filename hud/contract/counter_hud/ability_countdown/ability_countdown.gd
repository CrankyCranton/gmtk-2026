class_name AbilityCountdown extends TextureRect


@onready var count: Label = $Count


func init(ability_icon: Texture2D, ability_count: int) -> void:
	texture = ability_icon
	count.text = str(ability_count)
