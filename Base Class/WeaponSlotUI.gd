extends Control
class_name WeaponSlotUI

@export var name_label: Label
@export var damage_label: Label
@export var status_rect: ColorRect

var _weapon: Weapon

func bind(weapon: Weapon, is_current: bool) -> void:
	_weapon = weapon
	_update_visuals(is_current)

func _update_visuals(is_weapon_current: bool) -> void:
	if not _weapon:
		visible = false
		return
	
	name_label.text = _weapon.module_name
	var integrity = _weapon.get_integrity()
	var hp_ratio = integrity.get_ratio()
	name_label.modulate = Color.WHITE.lerp(Color.RED, 1 - hp_ratio)
	
	if not _weapon.is_active():
		status_rect.color = Color.RED
		damage_label.text = "OFFLINE"
		modulate.a = 0.5
	elif not _weapon.weapon_active:
		status_rect.color = Color.YELLOW
		damage_label.text = "RELOAD"
		modulate.a = 1
	else:
		status_rect.color = Color.GREEN
		damage_label.text = "DMG: %d" % _weapon.weapon_stats.damage
		modulate.a = 1
	
	if is_weapon_current and _weapon.is_active():
		self_modulate = Color.YELLOW
	else:
		self_modulate = Color.WHITE
