extends State
class_name PlayerIdle

func enterState():
	pass

func updateState(_delta : float):
	#MOVE
	if(Input.get_vector("move_left", "move_right", "move_up", "move_down")):
		#Transition to Run State
		transition.emit(self, "Run")
	
	#DASH
	var current_time = Time.get_ticks_msec() / 1000.0
	if Input.is_action_just_pressed("dash") and current_time >= (PLAYER.last_dash_time + PLAYER.dash_cooldown):
		transition.emit(self, "Dash")
		return
