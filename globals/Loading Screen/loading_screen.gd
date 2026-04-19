extends CanvasLayer

var target_scene_path : String = ""

func _ready():
	hide()
	set_process(false) # Turn off _process so it isn't constantly running in the background

# Call this function when you want to load a level
func load_level(path: String):
	target_scene_path = path
	
	# --- RANDOM FRAME LOGIC ---
	# Calculate the total frames based on your Inspector grid settings
	var total_frames = %PotionSprite.hframes * %PotionSprite.vframes
	
	# Pick a random frame between 0 and (total_frames - 1)
	var random_frame = randi() % total_frames
	
	# If the frame lands on a banned number, reroll until it doesn't
	while random_frame in [1, 2, 14]:
		random_frame = randi() % total_frames
		
	%PotionSprite.frame = random_frame
	
	# --- END RANDOM FRAME LOGIC ---
	
	show() # Make the loading screen visible
	
	# Ask Godot's background thread to start building the scene
	ResourceLoader.load_threaded_request(target_scene_path)
	
	# Turn on _process so we can monitor the load status
	set_process(true)

func _process(_delta):
	# Ask the ResourceLoader what the current status is (no progress array needed)
	var status = ResourceLoader.load_threaded_get_status(target_scene_path) 
	
	if status == ResourceLoader.THREAD_LOAD_LOADED: # Background thread finished building
		set_process(false)
		
		# Grab the fully built scene from the background thread
		var new_scene = ResourceLoader.load_threaded_get(target_scene_path)
		
		# Swap scenes
		get_tree().change_scene_to_packed(new_scene)
		
		# Hide loading screen and run transition
		hide()
		await get_tree().process_frame
		await get_tree().process_frame
		
		await ScreenTransition.trans_out().finished
		ScreenTransition.reset()
	
	# Failsafe in case the file path is wrong
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		print("ERROR: Could not load the level! File path is nonexistent")
		hide()
		set_process(false)
