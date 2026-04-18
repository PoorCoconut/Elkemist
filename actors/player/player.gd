extends CharacterBody2D
class_name Player

@export_category("PLAYER MOVEMENT")
@export var BASE_MAX_SPEED : float = 100.0
@export var ACCELERATION : float = 300.0
@export var FRICTION : float = 400.0

@export_category("DASH SETTINGS")
@export var dash_cooldown: float = 1.0 # 1 second cooldown

@export_category("COMPONENTS")
@export var dash_hitbox: ComponentHitbox

var CUR_DIR : Vector2 = Vector2.ZERO
var speed_modifiers: Dictionary = {}

var last_dash_time: float = -10.0 

# --- KNOCKBACK VARIABLES ---
var kb_direction: Vector2 = Vector2.ZERO
var kb_force: float = 0.0
var kb_duration: float = 0.0

func get_max_speed() -> float:
	var final_multiplier: float = 1.0
	
	for effect_id in speed_modifiers:
		final_multiplier *= speed_modifiers[effect_id]
		
	return BASE_MAX_SPEED * final_multiplier

func add_speed_modifier(effect_id: String, multiplier: float):
	speed_modifiers[effect_id] = multiplier

func remove_speed_modifier(effect_id: String):
	if speed_modifiers.has(effect_id):
		speed_modifiers.erase(effect_id)

func apply_knockback(direction: Vector2, force: float, duration: float):
	# 1. Store the incoming physics data so the state can read it
	kb_direction = direction
	kb_force = force
	kb_duration = duration
	
	# 2. Force the FSM to interrupt the current state and switch to Knockback
	var fsm = $FSM # Ensure this matches the exact name of your FSM node
	
	if fsm:
		# We loop through the FSM's children to find which state is currently active
		for state in fsm.get_children():
			$FSM.force_change_state("Knockback")
