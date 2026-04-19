extends CanvasLayer
class_name PlayerHUD

@export_category("Potion Hotbar")
# Drag your 4 hotbar TextureRect nodes into this array in the Inspector
@export var hotbar_slots: Array[TextureRect] 

@export_category("Potion Icons")
# Map the exact strings from your Cauldron RECIPES dictionary to your image files.
# Currently using your placeholder texture for all of them so the game won't crash.
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

func _ready() -> void:
	# Listen for the global broadcasts
	GameManager.inventory_updated.connect(update_ui)
	GameManager.cauldron_state_updated.connect(update_progress_bars)
	
	# Force an initial draw on startup
	update_ui()

func update_progress_bars() -> void:
	# Access them directly and apply the GameManager values
	%FuelProgress.value = GameManager.cauldron_fuel
	$BrewingProgress.value = GameManager.brew_progress * 100.0
	
	# Call the new color logic
	update_fuel_color(GameManager.cauldron_fuel)

func update_fuel_color(fuel: float) -> void:
	var current_color: Color
	
	# Set the color based on thresholds (assuming 100 is max fuel).
	# Adjust these numbers if you want the color changes to happen earlier/later.
	
	if fuel > 75.0:
		MusicManager.set_intensity(0.4, 1.0)
		current_color = Color.RED
	elif fuel > 50.0:
		MusicManager.set_intensity(0.6, 1.0)
		current_color = Color.ORANGE
	elif fuel > 25.0:
		MusicManager.set_intensity(1.0, 1.0)
		current_color = Color.YELLOW
	else:
		MusicManager.set_intensity(1.0, 1.0)
		current_color = Color.BLUE
		
	# Apply the color dynamically based on the node type
	if %FuelProgress is TextureProgressBar:
		%FuelProgress.tint_progress = current_color
	else:
		# Fallback for standard Control nodes
		%FuelProgress.modulate = current_color

func update_ui() -> void:
	# 1. Update the Raw Ingredient Labels
	%label1.text = str(GameManager.ingredients["firewood"])
	%label2.text = str(GameManager.ingredients["sunfruit"])
	%label3.text = str(GameManager.ingredients["kookaberry"])
	%label4.text = str(GameManager.ingredients["spicetooth"])
	%label5.text = str(GameManager.ingredients["monga"])
	
	# 2. Update the Potion Hotbar
	for i in range(hotbar_slots.size()):
		if i >= GameManager.potions.size():
			break
			
		var potion_name = GameManager.potions[i]
		
		# FIX 4: Ignore empty strings
		if potion_name != null and potion_name != "" and potion_textures.has(potion_name):
			hotbar_slots[i].texture = potion_textures[potion_name]
			hotbar_slots[i].modulate.a = 1.0 
		else:
			hotbar_slots[i].texture = null
