extends Node

signal log_signal(msg: String, color_name: String)
signal armor_update_signal(ship, location, value)

func battle_log(parts: Array, color_name := "Base"):
	var msg = "".join(parts)
	
	emit_signal("log_signal", msg, color_name)

func armor_update(ship, location, value):
	emit_signal("armor_update_signal", ship, location, value)
























