class_name Contract extends Label


var init_counters: Dictionary[String, int]


func _on_player_counters_changed(counters: Dictionary[String, int]) -> void:
	text = ""
	for counter: String in counters:
		text += "%s: %s/%s\n" % [counter, counters[counter], init_counters[counter]]


func _on_player_counters_initialized(counters: Dictionary[String, int]) -> void:
	init_counters = counters
	_on_player_counters_changed(counters)
