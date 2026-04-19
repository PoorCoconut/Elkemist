extends Node2D

func _ready() -> void:
	MusicManager.set_intensity(0.4, 2.0)
	MusicManager.change_music("Panacea", 0.0)
