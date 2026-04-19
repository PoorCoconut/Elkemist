extends State
class_name PlayerRun

func enterState():
	pass

func updateState(delta: float):
	movement(delta)

func movement(delta: float):
	# Calculate the current time in seconds
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Check for input AND ensure the cooldown has passed
	if Input.is_action_just_pressed("dash") and current_time >= (PLAYER.last_dash_time + (PLAYER.dash_cooldown * PLAYER.dash_cd_modifier)):
		transition.emit(self, "Dash")
		return
	
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# --- CONFUSION LOGIC START ---
	if PLAYER.is_confused:
		direction *= -1
	# --- CONFUSION LOGIC END ---
	
	if direction != Vector2.ZERO:
		PLAYER.CUR_DIR = direction
		
		# Fetch the dynamically calculated speed here
		var current_speed = PLAYER.get_max_speed()
		PLAYER.velocity = PLAYER.velocity.move_toward(direction * current_speed, PLAYER.ACCELERATION * delta)
	else:
		PLAYER.velocity = PLAYER.velocity.move_toward(Vector2.ZERO, PLAYER.FRICTION * delta)
	
	PLAYER.move_and_slide()
	
	if direction == Vector2.ZERO and PLAYER.velocity.length() < 5.0:
		transition.emit(self, "Idle")
