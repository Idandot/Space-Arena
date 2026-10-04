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
		weapon_label.text = "N/D"
		damage_label.text = "Damage: 0"
		return
	weapon_label.text = weapon.module_name
	damage_label.text = "Damage: %d" % weapon.weapon_stats.damage

func _on_phase_started(phase: Enums.game_states) -> void:
	if phase != Enums.game_states.ACTION:
		weapon_label.text = "N/D"
		damage_label.text = "Damage: 0"
		prev_weapon_button.disabled = true
		next_weapon_button.disabled = true
		return
	
	prev_weapon_button.disabled = false
	next_weapon_button.disabled = false
	return
