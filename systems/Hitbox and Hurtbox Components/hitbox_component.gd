extends Area2D
class_name ComponentHitbox

@export var knockback_force: float = 200.0

func _on_area_entered(area: Area2D) -> void:
	if area is ComponentHurtbox:
		var knockback_dir = (area.global_position - global_position).normalized()
		
		# Added get_parent() so the Hurtbox knows who the attacker is
		area.take_hit(knockback_force, knockback_dir, get_parent())
