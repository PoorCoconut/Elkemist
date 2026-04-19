extends Node

# Drag your MusicTrack resources into this array in the Inspector!
@export var music_tracks: Array[MusicTrack] = []
var track_db: Dictionary = {}

var active_players: Array[AudioStreamPlayer] = []
var current_intensity: float = 0.0
var current_track_name: String = ""

func _ready() -> void:
	# Build a dictionary so we can easily search tracks by their string name
	for track in music_tracks:
		track_db[track.track_name.to_lower()] = track

# Call this to fade between songs (e.g., change_music("forest", 3.0))
func change_music(track_name: String, crossfade_time: float = 2.0) -> void:
	var safe_name = track_name.to_lower()
	
	if not track_db.has(safe_name):
		push_error("MusicManager: Track '" + track_name + "' not found!")
		return
	if current_track_name == safe_name:
		return 
		
	current_track_name = safe_name
	var new_track: MusicTrack = track_db[safe_name]
	
	var fading_players = active_players.duplicate()
	active_players.clear()
	
	var tween = create_tween()
	
	for player in fading_players:
		tween.parallel().tween_property(player, "volume_db", -80.0, crossfade_time)
	tween.tween_callback(func(): _cleanup_players(fading_players))
	
	# Variables to track our Master Sync
	var longest_duration: float = 0.0
	var master_player: AudioStreamPlayer = null
	
	for i in range(new_track.stems.size()):
		var player = AudioStreamPlayer.new()
		player.stream = new_track.stems[i]
		player.volume_db = -80.0 
		player.bus = "Music" 
		
		add_child(player)
		player.play()
		active_players.append(player)
		
		var target_vol = _get_layer_volume(i, new_track.stems.size(), current_intensity)
		tween.parallel().tween_property(player, "volume_db", target_vol, crossfade_time)
		
		# Check if this track is the longest one we've seen so far
		var current_length = player.stream.get_length()
		if current_length > longest_duration:
			longest_duration = current_length
			master_player = player
			
	# Connect the longest track to our custom looping function
	if master_player:
		master_player.finished.connect(_on_master_track_finished)



# Call this to raise/lower the music tension (e.g., set_intensity(0.8))
func set_intensity(new_intensity: float, fade_time: float = 1.0) -> void:
	current_intensity = clamp(new_intensity, 0.0, 1.0)
	
	var tween = create_tween()
	for i in range(active_players.size()):
		var target_vol = _get_layer_volume(i, active_players.size(), current_intensity)
		tween.parallel().tween_property(active_players[i], "volume_db", target_vol, fade_time)

#Allows singular tracks to work perfectly alongside 5-layer tracks
func _get_layer_volume(index: int, total_layers: int, intensity: float) -> float:
	#Singular tracks OR the Base Layer (Index 0) always play at max volume
	if total_layers == 1 or index == 0:
		return 0.0 
		
	#Slice the intensity pie. If we have 3 layers, layer 1 fades in at 0.5, layer 2 at 1.0
	var slice = 1.0 / float(total_layers - 1)
	var start_fade = slice * (index - 1)
	var full_volume = slice * index
	
	#Calculate a 0.0 to 1.0 weight for this specific layer
	var weight = clamp((intensity - start_fade) / (full_volume - start_fade), 0.0, 1.0)
	
	if weight <= 0.01:
		return -80.0
	return linear_to_db(weight)

func _cleanup_players(players_to_kill: Array[AudioStreamPlayer]) -> void:
	for p in players_to_kill:
		p.queue_free()

func stop_music(fade_out_time: float = 2.0) -> void:
	if active_players.is_empty():
		return # Nothing is playing so do nothing
		
	#Move all currently playing stems to the chopping block
	var fading_players = active_players.duplicate()
	
	#Clear the active list and reset the track name so it can be played again later
	active_players.clear()
	current_track_name = ""
	
	#Fade them all to silence smoothly
	var tween = create_tween()
	for player in fading_players:
		tween.parallel().tween_property(player, "volume_db", -80.0, fade_out_time)
		
	#Delete the audio nodes once the fade-out is complete
	tween.tween_callback(func(): _cleanup_players(fading_players))

# ADD THIS NEW FUNCTION AT THE BOTTOM OF YOUR SCRIPT
func _on_master_track_finished() -> void:
	# When the longest track ends, immediately restart all active players from 0.0
	for player in active_players:
		player.play(0.0)
