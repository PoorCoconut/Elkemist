extends Control
class_name GameOverMenu

@export_file("*.tscn") var next_level_path : String
func _ready() -> void:
	MusicManager.set_intensity(0.0, 2)
	MusicManager.change_music("Panacea", 0.0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		set_process_unhandled_input(false) 
		
		GameManager.load_next_level(next_level_path)
