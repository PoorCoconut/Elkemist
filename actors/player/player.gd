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

var is_confused: bool = false

# --- KNOCKBACK VARIABLES ---
var kb_direction: Vector2 = Vector2.ZERO
var kb_force: float = 0.0
var kb_duration: float = 0.0

#Variables for the potion stuff owefbouawfeboubef
var dash_cd_modifier: float = 1.0
var dash_speed_modifier: float = 1.0
var is_guarded: bool = false
var is_ramming: bool = false


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
	if is_guarded:
		return # Block the knockback completely:
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

func update_facing_direction() -> void:
	var sprite = $Sprite
	
	if sprite:
		# Since your base art faces LEFT:
		# Moving right (positive X) means we need to flip it.
		if CUR_DIR.x > 0:
			sprite.flip_h = true
		# Moving left (negative X) means we return to the default art.
		elif CUR_DIR.x < 0:
			sprite.flip_h = false
		# If CUR_DIR.x == 0, we do nothing, letting the Elk stay facing its last direction.

func _physics_process(delta: float) -> void:
	update_facing_direction()

func _unhandled_input(event: InputEvent) -> void:
	# Listen for physical keyboard numbers 1 through 4
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_1:
			try_consume_potion(0)
		elif event.keycode == KEY_2:
			try_consume_potion(1)
		elif event.keycode == KEY_3:
			try_consume_potion(2)
		elif event.keycode == KEY_4:
			try_consume_potion(3)

func try_consume_potion(slot_index: int) -> void:
	SoundBank.play_global_sfx("drink")
	
	# 1. Verify the slot isn't out of bounds
	if slot_index >= GameManager.potions.size(): 
		return
		
	var potion_name = GameManager.potions[slot_index]

	# 2. Verify we actually have a potion to drink
	if potion_name == null or potion_name == "":
		return 

	# 3. Clear the item from the inventory and update UI
	GameManager.potions[slot_index] = ""
	GameManager.inventory_updated.emit()

	# 4. Apply the effect
	apply_potion_effect(potion_name)

func apply_potion_effect(potion_name: String) -> void:
	print("Consumed: ", potion_name)
	
	match potion_name:
		"potion_slop":
			is_confused = true
			add_speed_modifier("slop_sickness", 0.5)
			
			var random_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
			apply_knockback(random_dir, 400.0, 0.5)
			
			GameManager.add_active_potion(potion_name)
			
			get_tree().create_timer(5.0).timeout.connect(func(): 
				is_confused = false
				remove_speed_modifier("slop_sickness")
				GameManager.remove_active_potion(potion_name)
			)
			
		"potion_reaction":
			dash_cd_modifier = 0.5 
			GameManager.add_active_potion(potion_name)
			
			get_tree().create_timer(10.0).timeout.connect(func(): 
				dash_cd_modifier = 1.0
				GameManager.remove_active_potion(potion_name)
			)
			
		"potion_ramming":
			# Ramming now makes you a bulldozer (immune to knockback)
			is_guarded = true 
			GameManager.add_active_potion(potion_name)
			
			get_tree().create_timer(10.0).timeout.connect(func(): 
				is_guarded = false
				GameManager.remove_active_potion(potion_name)
			)
			
		"potion_swiftness":
			add_speed_modifier("swiftness_buff", 1.5) 
			GameManager.add_active_potion(potion_name) 
			
			get_tree().create_timer(10.0).timeout.connect(func(): 
				remove_speed_modifier("swiftness_buff")
				GameManager.remove_active_potion(potion_name) 
			)
			
		"potion_guarding":
			# Guarding now makes you a ghost (phases through obstacles)
			is_ramming = true 
			GameManager.add_active_potion(potion_name)
			
			get_tree().create_timer(10.0).timeout.connect(func(): 
				is_ramming = false
				GameManager.remove_active_potion(potion_name)
			)
			
		"potion_leaping":
			dash_speed_modifier = 1.5 
			GameManager.add_active_potion(potion_name)
			
			get_tree().create_timer(10.0).timeout.connect(func(): 
				dash_speed_modifier = 1.0
				GameManager.remove_active_potion(potion_name)
			)
			
		"potion_burning":
			GameManager.fuel_drain_modifier = 0.5 
			GameManager.add_active_potion(potion_name)
			
			get_tree().create_timer(10.0).timeout.connect(func(): 
				GameManager.fuel_drain_modifier = 1.0
				GameManager.remove_active_potion(potion_name)
			)
			
		_:
			print("Potion effect not implemented yet!")
