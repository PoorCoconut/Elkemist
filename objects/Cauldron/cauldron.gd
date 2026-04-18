extends StaticBody2D
class_name Cauldron

@export_category("CAULDRON STATS")
@export var max_fuel: float = 100.0
@export var fuel_drain_rate: float = 3.0 # Drains 3 points per second
@export var fuel_restore_amount: float = 25.0
@export var brew_time_required: float = 3.0 # Seconds to finish a potion

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
			# TODO: Trigger Game Over or Fire Out logic here
	
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
	%label1.text = str(GameManager.ingredients["firewood"])
	%label2.text = str(GameManager.ingredients["sunfruit"])
	%label3.text = str(GameManager.ingredients["kookaberry"])
	%label4.text = str(GameManager.ingredients["spicetooth"])
	%label5.text = str(GameManager.ingredients["monga"])

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is Player:
		%CauldronUI.show()

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body is Player:
		%CauldronUI.hide()

# --- BREWING LOGIC ---
# Keys MUST be alphabetically sorted (e.g., 'a_b', not 'b_a')
const RECIPES: Dictionary = {
	"kookaberry_sunfruit": "potion_healing",
	"monga_spicetooth": "potion_speed",
	"sunfruit_sunfruit": "potion_stamina",
	"kookaberry_spicetooth": "potion_fire",
	# Add the rest of your intended combinations here
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

func finish_brew() -> void:
	is_brewing = false
	var item_1 = brew_buffer[0]
	var item_2 = brew_buffer[1]
	brew_buffer.clear()
	
	# 1. Standardize the input by sorting alphabetically
	var ingredients = [item_1, item_2]
	ingredients.sort()
	var recipe_key = ingredients[0] + "_" + ingredients[1]
	
	# 2. Check the dictionary for a match
	var resulting_potion = "potion_sludge" # Default fallback
	if RECIPES.has(recipe_key):
		resulting_potion = RECIPES[recipe_key]
		
	# 3. Try to push it to the GameManager's hotbar
	var added_to_hotbar = false
	for i in range(GameManager.potions.size()):
		if GameManager.potions[i] == null:
			GameManager.potions[i] = resulting_potion
			added_to_hotbar = true
			
			# Tell the HUD to redraw the hotbar
			GameManager.inventory_updated.emit() 
			print("Successfully brewed and stored: ", resulting_potion)
			break
			
	# 4. Handle a full inventory
	if not added_to_hotbar:
		print("Inventory full! " + resulting_potion + " dropped on the ground.")
		# TODO: Instantiate a physical potion drop here so it isn't lost forever

##UI STUFF

func _on_fuel_pressed() -> void:
	# Only consume firewood if the fuel isn't completely maxed out
	if current_fuel < max_fuel:
		if GameManager.consume_ingredient("firewood"):
			# clamp() prevents the fuel from exceeding the maximum limit
			current_fuel = clamp(current_fuel + fuel_restore_amount, 0.0, max_fuel)

func _on_sunfruit_button_pressed() -> void:
	pass # Replace with function body.

func _on_kookaberry_button_pressed() -> void:
	pass # Replace with function body.

func _on_spicetooth_button_pressed() -> void:
	pass # Replace with function body.

func _on_monga_button_pressed() -> void:
	pass # Replace with function body.

func _on_inv_1_button_pressed() -> void:
	pass # Replace with function body.

func _on_inv_2_button_pressed() -> void:
	pass # Replace with function body.

func _on_inv_3_button_pressed() -> void:
	pass # Replace with function body.

func _on_inv_4_button_pressed() -> void:
	pass # Replace with function body.
