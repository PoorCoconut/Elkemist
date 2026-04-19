extends Area2D
class_name SpicetoothVine

@export_category("DROP SETTINGS")
@export var resource_scene: PackedScene
@export var knockback_force: float = 800.0
@export var knockback_duration: float = 0.2

var player_in_range: bool = false
var target_player: Player = null
var has_spicetooth: bool = true

func _ready() -> void:
	# Connect the Area2D signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and has_spicetooth and target_player:
		if event.is_action_pressed("interact"):
			detonate_and_harvest()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		target_player = body

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		target_player = null

func detonate_and_harvest() -> void:
	GameManager.do_camera_shake(4.0, 0.5)
	has_spicetooth = false
	
	# 1. Spawn TWO Spicetooth drops
	if resource_scene:
		for i in range(2):
			var drop = resource_scene.instantiate()
			drop.resource_type = ResourceDrop.RESOURCE_TYPE.SPICETOOTH
			
			# Offset the first one slightly left, and the second one slightly right
			var offset = Vector2(-15 if i == 0 else 15, 10)
			drop.global_position = global_position + offset
			
			get_tree().current_scene.add_child(drop)

	# 2. Apply Knockback (towards the mouse pointer)
	if target_player.has_method("apply_knockback"):
		var mouse_pos = get_global_mouse_position()
		
		# Direction FROM the player TO the mouse
		var knockback_dir = target_player.global_position.direction_to(mouse_pos)
		
		# Send the physics data to the Elk
		target_player.apply_knockback(knockback_dir, knockback_force, knockback_duration)
	else:
		print("Spicetooth detonated, but Player is missing apply_knockback()!")

	# 3. Destroy the vine
	queue_free()
