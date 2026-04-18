extends State
class_name PlayerKnockback

@export var knockback_friction: float = 2500.0
var kb_timer: float = 0.0

func enterState():
	# Pull the specific numbers that were saved on the base player script
	kb_timer = PLAYER.kb_duration
	PLAYER.velocity = PLAYER.kb_direction * PLAYER.kb_force

func updateState(delta: float):
	# Apply friction so the explosion naturally slows down over the duration
	PLAYER.velocity = PLAYER.velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
	
	PLAYER.move_and_slide()
	
	kb_timer -= delta
	
	# When the explosion stun ends, give control back to the player
	if kb_timer <= 0.0:
		if Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
			transition.emit(self, "Run")
		else:
			PLAYER.velocity = Vector2.ZERO 
			transition.emit(self, "Idle")
