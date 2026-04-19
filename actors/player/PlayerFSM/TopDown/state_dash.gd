extends State
class_name PlayerDash

@export var dash_speed: float = 400.0 
@export var dash_friction: float = 1000.0
@export var dash_duration: float = 0.25

var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

func enterState():
	dash_timer = dash_duration
	PLAYER.last_dash_time = Time.get_ticks_msec() / 1000.0
	
	# Turn the hitbox ON safely
	if PLAYER.dash_hitbox:
		var shape = PLAYER.dash_hitbox.get_node("CollisionShape2D")
		shape.set_deferred("disabled", false)
	
	dash_direction = PLAYER.global_position.direction_to(PLAYER.get_global_mouse_position())
	
	# --- CONFUSION LOGIC START ---
	if PLAYER.is_confused:
		dash_direction *= -1
	# --- CONFUSION LOGIC END ---
	
	PLAYER.velocity = dash_direction * (dash_speed * PLAYER.dash_speed_modifier)
	
	if PLAYER.is_ramming:
		PLAYER.set_collision_mask_value(1, false)

func updateState(delta: float):
	PLAYER.velocity = PLAYER.velocity.move_toward(Vector2.ZERO, dash_friction * delta)
	PLAYER.move_and_slide()
	
	dash_timer -= delta
	
	if dash_timer <= 0.0 or PLAYER.is_on_wall():
		if Input.get_vector("move_left", "move_right", "move_up", "move_down") != Vector2.ZERO:
			transition.emit(self, "Run")
		else:
			PLAYER.velocity = Vector2.ZERO 
			transition.emit(self, "Idle")

# ADDED exitState to guarantee the hitbox turns off no matter what interrupts the dash
func exitState():
	if PLAYER.dash_hitbox:
		var shape = PLAYER.dash_hitbox.get_node("CollisionShape2D")
		shape.set_deferred("disabled", true)
	# Turn wall collisions safely back on
	PLAYER.set_collision_mask_value(1, true)
