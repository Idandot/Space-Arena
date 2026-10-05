extends HBoxContainer

@export var prev_weapon_button: Button
@export var next_weapon_button: Button
@export var weapon_label: Label
@export var damage_label: Label
var weapon_shown: Weapon

func _ready() -> void:
	GameEvents.active_weapon_changed.connect(_on_active_weapon_changed)
	TurnManager.phase_started.connect(_on_phase_started)

func _on_active_weapon_changed(weapon: Weapon) -> void:
	if weapon_label == null:
		return
	if weapon == null:
		_clear_weapon_data()
		return
	
	weapon_label.text = weapon.module_name
	var module_integrity = weapon.get_integrity()
	var hp_ratio: float = float(module_integrity.current) / float(module_integrity.maximum)
	weapon_label.modulate = Color(1,1,1,1).lerp(Color(1, 0.2, 0.2, 1), 1.0 - hp_ratio)
	
	if module_integrity.current <= 0:
		damage_label.text = "Damage: 0"
	else:
		damage_label.text = "Damage: %d" % weapon.weapon_stats.damage

func _on_phase_started(phase: Enums.game_states) -> void:
	if phase != Enums.game_states.ACTION:
		_clear_weapon_data()
		_togge_buttons(true)
		return
	
	_togge_buttons(false)
	return

func _clear_weapon_data() -> void:
	if weapon_label != null:
		weapon_label.text = "N/D"
	if damage_label != null:
		damage_label.text = "Damage: 0"

func _togge_buttons(enable:= true) -> void:
	prev_weapon_button.disabled = enable
	next_weapon_button.disabled = enable
