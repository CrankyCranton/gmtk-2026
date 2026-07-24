class_name Contract extends HBoxContainer


#var init_counters: Dictionary[String, int]
#
#
#func _on_player_counters_changed(counters: Dictionary[String, int]) -> void:
	#for counter: String in counters:
		#var counter_hud: CounterHud = get_node(NodePath(counter))
		#counter_hud.set_counter(counters[counter])
	##text = ""
	##for counter: String in counters:
		##text += "%s: %s/%s\n" % [counter, counters[counter], init_counters[counter]]
#
#
#func _on_player_counters_initialized(counters: Dictionary[String, int]) -> void:
	#init_counters = counters
	#for counter: String in counters:
		#print(counter)
		#var counter_hud: CounterHud = preload("uid://cy5owm7cbyder").instantiate()
		#counter_hud.name = counter
		#add_child(counter_hud, true)
		#counter_hud.set_type(counter)
	#_on_player_counters_changed(counters)


func _on_player_time_changed(time: float) -> void:
	$CounterHUD.set_counter(time)
