extends Node

var CURRENT_WORLD_STATE : String = "Nothing"
const SAVE_PATH : String = "user://savegame.json"

func _ready() -> void:
	print("GAME MANAGER LOADED!")

## INVENTORY SYSTEM
signal inventory_updated

const MAX_INGREDIENT_CAP : int = 10

# The base resources that stack
var ingredients: Dictionary = {
	"firewood": 0,
	"sunfruit": 0,
	"kookaberry": 0,
	"spicetooth": 0,
	"monga": 0
}

# The 4-slot potion hotbar. 'null' means empty, otherwise it holds a string ID like "potion_red"
var potions: Array = [null, null, null, null]

#For the cauldron
var fuel_drain_modifier: float = 1.0

signal active_potions_changed

var active_potions: Array[String] = []

func add_active_potion(potion_name: String) -> void:
	active_potions.append(potion_name)
	active_potions_changed.emit()

func remove_active_potion(potion_name: String) -> void:
	# erase() only removes the first instance it finds, which is safe enough here
	active_potions.erase(potion_name)
	active_potions_changed.emit()

func add_ingredient(item_name: String, amount: int = 1) -> bool:
	if ingredients.has(item_name):
		if ingredients[item_name] < MAX_INGREDIENT_CAP:
			ingredients[item_name] += amount
			
			# Clamp the value so it never exceeds the max cap
			if ingredients[item_name] > MAX_INGREDIENT_CAP:
				ingredients[item_name] = MAX_INGREDIENT_CAP
				
			# Tell all UI menus to refresh their numbers
			inventory_updated.emit() 
			return true # Successfully picked up
			
		else:
			print("Inventory full for: ", item_name)
			return false # Failed to pick up, item stays on ground
	return false

##CAULDRON STUFF
var cauldron_fuel: float = 100.0
var brew_progress: float = 0.0 # Will be a value between 0.0 and 1.0
signal cauldron_state_updated

# A helper function to safely subtract ingredients when a button is clicked
func consume_ingredient(item_name: String) -> bool:
	if ingredients.has(item_name) and ingredients[item_name] > 0:
		ingredients[item_name] -= 1
		inventory_updated.emit()
		return true
	return false

##SAVE FILE LOGIC
func save_player_position(player_pos: Vector2) -> void:
	var save_data = {
		"player_x": player_pos.x,
		"player_y": player_pos.y
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	print("Game Saved!")

func load_player_position():
	#Check if the player has ever saved the game before
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Starting from the bottom!")
		return null # Returning null lets the Player node know to use its default spawn
		
	#Open the file and read the text
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_text = file.get_as_text()
	
	#Parse the JSON back into a dictionary
	var save_data = JSON.parse_string(json_text)
	
	#Extract the coordinates and return them as a usable Vector2
	if save_data and save_data.has("player_x") and save_data.has("player_y"):
		var loaded_pos = Vector2(save_data["player_x"], save_data["player_y"])
		print("Save loaded! Teleporting player to: ", loaded_pos)
		return loaded_pos
	return null

##Next Level Helper Functions
func load_next_level(next_level_path : String) -> void:
	await ScreenTransition.trans_in().finished
	LoadingScreen.load_level(next_level_path)

##Camera Helper Functions
func do_camera_shake(intensity:float, time:float):
	if get_tree().get_first_node_in_group("camera"):
		var camera = get_tree().get_first_node_in_group("camera")
		var camera_tween = get_tree().create_tween()
		camera_tween.tween_method(camera.startCameraShake, intensity, 1.0, time)
		camera.startCameraShake(intensity)
		await get_tree().create_timer(time).timeout
		camera.resetCameraOffset()

func move_camera_to_player(player_pos : Vector2):
	if get_tree().get_first_node_in_group("camera"):
		var camera = get_tree().get_first_node_in_group("camera")
		camera.moveCameraToEntity(player_pos)
