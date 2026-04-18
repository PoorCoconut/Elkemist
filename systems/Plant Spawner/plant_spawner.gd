extends Node2D
class_name PlantSpawner

@export_category("Arena Bounds")
@export var spawn_radius: float = 1000.0 
@export var center_exclusion_radius: float = 250.0 

@export_category("Spawn Rules")
@export var min_distance_between_plants: float = 120.0 
@export var amount_per_plant: int = 5 
@export var max_spawn_attempts: int = 50 
@export var respawn_check_interval: float = 10.0 # Checks every 10 seconds

@export_category("Plant Scenes")
@export var sunfruit_scene: PackedScene
@export var firewood_scene: PackedScene
@export var kookaberry_scene: PackedScene
@export var spicetooth_scene: PackedScene
@export var monga_scene: PackedScene

# Maps the PackedScene to an array of its currently living instantiated nodes
var plant_registry: Dictionary = {}
var time_since_last_check: float = 0.0

func _ready() -> void:
	var plant_types = [
		sunfruit_scene, firewood_scene, kookaberry_scene, spicetooth_scene, monga_scene
	]
	
	for scene in plant_types:
		if scene != null:
			plant_registry[scene] = []
			spawn_missing_plants(scene)

func _process(delta: float) -> void:
	time_since_last_check += delta
	if time_since_last_check >= respawn_check_interval:
		time_since_last_check = 0.0
		
		# Run a check on every registered plant type to see if any are missing
		for scene in plant_registry.keys():
			spawn_missing_plants(scene)

func spawn_missing_plants(scene: PackedScene) -> void:
	var active_instances = plant_registry[scene]
	
	# Clean up the array: Remove any references to plants the player destroyed
	for i in range(active_instances.size() - 1, -1, -1):
		if not is_instance_valid(active_instances[i]):
			active_instances.remove_at(i)
			
	var missing_count = amount_per_plant - active_instances.size()
	
	for i in range(missing_count):
		var valid_pos = get_valid_spawn_position()
		
		if valid_pos != Vector2.INF:
			var plant_instance = scene.instantiate()
			plant_instance.global_position = valid_pos
			get_tree().current_scene.call_deferred("add_child", plant_instance)
			
			active_instances.append(plant_instance)

func get_valid_spawn_position() -> Vector2:
	# Gather the physical locations of every single plant currently alive
	var all_living_plants = []
	for active_list in plant_registry.values():
		all_living_plants.append_array(active_list)

	for attempt in range(max_spawn_attempts):
		var random_x = randf_range(-spawn_radius, spawn_radius)
		var random_y = randf_range(-spawn_radius, spawn_radius)
		var test_pos = global_position + Vector2(random_x, random_y)
		
		if test_pos.distance_to(global_position) < center_exclusion_radius:
			continue 
			
		var is_too_close = false
		for plant in all_living_plants:
			# Ensure the plant still exists before checking its position
			if is_instance_valid(plant):
				if test_pos.distance_to(plant.global_position) < min_distance_between_plants:
					is_too_close = true
					break 
				
		if is_too_close:
			continue 
			
		return test_pos
		
	return Vector2.INF
