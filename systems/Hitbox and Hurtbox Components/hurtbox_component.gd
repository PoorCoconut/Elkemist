extends Area2D
class_name ComponentHurtbox

# Added 'attacker' to the signal
signal on_hit_received(knockback: float, direction: Vector2, attacker: Node2D)

func take_hit(knockback: float, direction: Vector2, attacker: Node2D):
	on_hit_received.emit(knockback, direction, attacker)
