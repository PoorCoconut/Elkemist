extends Node2D

func _ready() -> void:
	# --- 1. RESET GLOBAL STATE ---
	GameManager.active_potions.clear()
	
	GameManager.cauldron_fuel = 100.0
	GameManager.brew_progress = 0.0
	GameManager.fuel_drain_modifier = 1.0
	
	# Clear the hotbar (Using empty strings to prevent the null error)
	GameManager.potions = ["", "", "", ""]
	
	# Empty the raw materials
	GameManager.ingredients = {
		"firewood": 0,
		"sunfruit": 0,
		"kookaberry": 0,
		"spicetooth": 0,
		"monga": 0
	}
	
	# --- 2. FORCE UI UPDATES ---
	# Tell the Cauldron and HUD to redraw themselves so they don't show old data
	GameManager.inventory_updated.emit()
	GameManager.cauldron_state_updated.emit()
	
	# --- 3. START AUDIO ---
	MusicManager.set_intensity(0.4, 2.0)
	MusicManager.change_music("Panacea", 0.0)
