extends StaticBody2D
class_name Cauldron

@export_category("CAULDRON STATS")
@export var max_fuel: float = 100.0
@export var fuel_drain_rate: float = 3.0 # Drains 3 points per second
@export var fuel_restore_amount: float = 25.0
@export var brew_time_required: float = 3.0 # Seconds to finish a potion

@export_category("Potion Icons")
@export var potion_textures: Dictionary = {
	"potion_slop": preload("res://game_assets/potions/p_slop.tres"),
	
	# --- TIER 1 ---
	"potion_reaction": preload("res://game_assets/potions/p_reaction.tres"),
	"potion_ramming": preload("res://game_assets/potions/p_ramming.tres"),
	"potion_swiftness": preload("res://game_assets/potions/p_swiftness.tres"),
	"potion_guarding": preload("res://game_assets/potions/p_guarding.tres"),
	"potion_leaping": preload("res://game_assets/potions/p_leaping.tres"),
	"potion_burning": preload("res://game_assets/potions/p_burning.tres"),
	
	# --- TIER 2 ---
	"potion_elixir": preload("res://game_assets/potions/p_x.tres"),
	"potion_inferno": preload("res://game_assets/potions/p_y.tres"),
	"potion_juggernaut": preload("res://game_assets/potions/p_z.tres"),
	
	# --- TIER 3 ---
	"potion_unstable_missing_juggernaut": preload("res://game_assets/potions/p_unstable_panacea.tres"),
	"potion_unstable_missing_inferno": preload("res://game_assets/potions/p_unstable_panacea.tres"),
	"potion_unstable_missing_elixir": preload("res://game_assets/potions/p_unstable_panacea.tres"),
	
	# --- TIER 4 ---
	"potion_panacea": preload("res://game_assets/potions/p_panacea.tres")
}

var current_fuel: float = 100.0
var brew_buffer: Array[String] = []
var current_brew_time: float = 0.0
var is_brewing: bool = false

func _ready() -> void:
	%CauldronUI.hide()
	GameManager.inventory_updated.connect(update_ui)
	update_ui()

func _process(delta: float) -> void:
	# 1. Drain the fuel
	if current_fuel > 0:
		current_fuel -= fuel_drain_rate * delta
		if current_fuel <= 0:
			current_fuel = 0.0
			GameManager.load_next_level("res://game_scenes/menus/Game Over Menu/game_over_menu.tscn")
	
	# 2. Progress the brew ONLY if the fire is lit
	if is_brewing and current_fuel > 0:
		current_brew_time += delta
		GameManager.brew_progress = current_brew_time / brew_time_required
		
		if current_brew_time >= brew_time_required:
			finish_brew()
	else:
		if not is_brewing:
			GameManager.brew_progress = 0.0
			
	# 3. Constantly update the GameManager so the HUD can read it
	GameManager.cauldron_fuel = current_fuel
	GameManager.cauldron_state_updated.emit()

func update_ui() -> void:
	# 1. Update ingredient text
	%label1.text = str(GameManager.ingredients["firewood"])
	%label2.text = str(GameManager.ingredients["sunfruit"])
	%label3.text = str(GameManager.ingredients["kookaberry"])
	%label4.text = str(GameManager.ingredients["spicetooth"])
	%label5.text = str(GameManager.ingredients["monga"])
	
	# 2. Update potion button icons
	var inv_buttons = [%Inv1Button, %Inv2Button, %Inv3Button, %Inv4Button]
	for i in range(inv_buttons.size()):
		var potion_name = GameManager.potions[i]
		
		# FIX 4: Ignore empty strings
		if potion_name != null and potion_name != "" and potion_textures.has(potion_name):
			inv_buttons[i].texture_normal = potion_textures[potion_name]
		else:
			inv_buttons[i].texture_normal = null

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is Player:
		%CauldronUI.show()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body is Player:
		%CauldronUI.hide()

# --- BREWING LOGIC ---
# Keys MUST be alphabetically sorted (e.g., 'a_b', not 'b_a')
const RECIPES: Dictionary = {
	
	# --- TIER 1 (Raw + Raw) ---
	"kookaberry_monga": "potion_leaping",
	"kookaberry_spicetooth": "potion_guarding",
	"kookaberry_sunfruit": "potion_reaction",
	"monga_spicetooth": "potion_ramming",
	"monga_sunfruit": "potion_swiftness",
	"spicetooth_sunfruit": "potion_burning",
	
	# --- TIER 2 (Tier 1 + Tier 1) ---
	# Reaction + Ramming -> Elixir
	"potion_ramming_potion_reaction": "potion_elixir",       
	# Guarding + Swiftness -> Inferno
	"potion_guarding_potion_swiftness": "potion_inferno",    
	# Burning + Leaping -> Juggernaut
	"potion_burning_potion_leaping": "potion_juggernaut", 
	
	# --- TIER 3 (Tier 2 + Tier 2) ---
	"potion_elixir_potion_inferno": "potion_unstable_missing_juggernaut",
	"potion_elixir_potion_juggernaut": "potion_unstable_missing_inferno",
	"potion_inferno_potion_juggernaut": "potion_unstable_missing_elixir",
	
	# --- TIER 4 (Tier 3 + Missing Tier 2) ---
	"potion_juggernaut_potion_unstable_missing_juggernaut": "potion_panacea",
	"potion_inferno_potion_unstable_missing_inferno": "potion_panacea",
	"potion_elixir_potion_unstable_missing_elixir": "potion_panacea"
}

func try_add_ingredient(item_name: String) -> void:
	# Block input if already brewing or buffer is full
	if is_brewing or brew_buffer.size() >= 2:
		return 
		
	# Try to consume the item. If successful, put it in the pot.
	if GameManager.consume_ingredient(item_name):
		brew_buffer.append(item_name)
		
		# If two items are in, start the clock
		if brew_buffer.size() == 2:
			is_brewing = true
			current_brew_time = 0.0

func try_add_potion(slot_index: int) -> void:
	if is_brewing or brew_buffer.size() >= 2:
		return 
		
	var potion_name = GameManager.potions[slot_index]
	# FIX 3: Ensure we aren't trying to add an empty string to the pot
	if potion_name != null and potion_name != "":
		# Replace with an empty string instead of null
		GameManager.potions[slot_index] = "" 
		
		brew_buffer.append(potion_name)
		GameManager.inventory_updated.emit()
		
		if brew_buffer.size() == 2:
			is_brewing = true
			current_brew_time = 0.0

func finish_brew() -> void:
	is_brewing = false
	var item_1 = brew_buffer[0]
	var item_2 = brew_buffer[1]
	brew_buffer.clear()
	
	var ingredients = [item_1, item_2]
	ingredients.sort()
	var recipe_key = ingredients[0] + "_" + ingredients[1]
	
	# FIX 1: Change sludge to slop so the UI can find the image
	var resulting_potion = "potion_slop" 
	if RECIPES.has(recipe_key):
		resulting_potion = RECIPES[recipe_key]
		
	var added_to_hotbar = false
	for i in range(GameManager.potions.size()):
		# FIX 2: Check for empty strings, not just null
		if GameManager.potions[i] == null or GameManager.potions[i] == "":
			GameManager.potions[i] = resulting_potion
			added_to_hotbar = true
			GameManager.inventory_updated.emit() 
			print("Successfully brewed and stored: ", resulting_potion)
			break
			
	if not added_to_hotbar:
		print("Inventory full! " + resulting_potion + " dropped on the ground.")

##UI STUFF

func _on_fuel_pressed() -> void:
	# Only consume firewood if the fuel isn't completely maxed out
	if current_fuel < max_fuel:
		if GameManager.consume_ingredient("firewood"):
			# clamp() prevents the fuel from exceeding the maximum limit
			current_fuel = clamp(current_fuel + fuel_restore_amount, 0.0, max_fuel)

# --- RAW INGREDIENT BUTTONS ---
func _on_sunfruit_button_pressed() -> void:
	try_add_ingredient("sunfruit")

func _on_kookaberry_button_pressed() -> void:
	try_add_ingredient("kookaberry")

func _on_spicetooth_button_pressed() -> void:
	try_add_ingredient("spicetooth")

func _on_monga_button_pressed() -> void:
	try_add_ingredient("monga")

# --- POTION INVENTORY BUTTONS ---
func _on_inv_1_button_pressed() -> void:
	try_add_potion(0)

func _on_inv_2_button_pressed() -> void:
	try_add_potion(1)

func _on_inv_3_button_pressed() -> void:
	try_add_potion(2)

func _on_inv_4_button_pressed() -> void:
	try_add_potion(3)
