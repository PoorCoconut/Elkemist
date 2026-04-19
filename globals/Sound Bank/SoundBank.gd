extends Node

#Store sound effects here...
var sfx_dict : Dictionary = {
	"berry" : preload("res://sound/sfx/sfx_berry.mp3"),
	"brew_done" : preload("res://sound/sfx/sfx_brew_done.mp3"),
	"button" : preload("res://sound/sfx/sfx_button.mp3"),
	"collect" : preload("res://sound/sfx/sfx_collect.mp3"),
	"death" : preload("res://sound/sfx/sfx_death.mp3"),
	"drink" : preload("res://sound/sfx/sfx_drink_potion.mp3"),
	"explosion" : preload("res://sound/sfx/sfx_explosion.mp3"),
	"wood_gone" : preload("res://sound/sfx/sfx_wood_gone.mp3"),
}

#Here is an example:
#"swing_sword": preload("res://audio/sfx/swing.ogg"),
#"jump": preload("res://audio/sfx/jump.ogg"),
#"slide_friction": preload("res://audio/sfx/friction.wav")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_sfx(sfx_name : String, spawn_pos : Vector2) -> void:
	#Check if sound exists
	if not sfx_dict.has(sfx_name):
		push_error("GameManager: SFX '" + sfx_name + "' not found in dictionary.")
		return
		
	#Create an audio player
	var sfx_player = AudioStreamPlayer2D.new()
	
	#Give it the specific sound from the dictionary and set its position
	sfx_player.stream = sfx_dict[sfx_name]
	sfx_player.global_position = spawn_pos
	sfx_player.pitch_scale = randf_range(0.7, 1.2) #Change these values for more variation of the sounds
	sfx_player.bus = "SFX"
	
	#Add it to the GameManager, play it, and queue_free when done
	add_child(sfx_player)
	sfx_player.finished.connect(sfx_player.queue_free)
	sfx_player.play()

func play_global_sfx(sfx_name: String) -> void:
	# 1. Check if sound exists
	if not sfx_dict.has(sfx_name):
		push_error("GameManager: SFX '" + sfx_name + "' not found in dictionary.")
		return
		
	# 2. Create a standard audio player (NOT 2D)
	var sfx_player = AudioStreamPlayer.new()
	
	# 3. Assign the sound and bus
	sfx_player.stream = sfx_dict[sfx_name]
	sfx_player.bus = "SFX"
	
	# Optional: Slight pitch variation keeps UI sounds from getting annoying
	sfx_player.pitch_scale = randf_range(0.9, 1.1) 
	
	# 4. Add to tree, play, and destroy when finished
	add_child(sfx_player)
	sfx_player.finished.connect(sfx_player.queue_free)
	sfx_player.play()
