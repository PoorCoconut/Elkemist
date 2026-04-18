extends Area2D
class_name MongaSprout

@export_category("DROP SETTINGS")
@export var resource_scene: PackedScene
@export var required_hold_time: float = 1.0

var hold_time: float = 0.0
var is_holding: bool = false
var player_in_range: bool = false
var has_monga: bool = true

func _ready() -> void:
	# Connect the signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if not has_monga: 
		return
		
	if event.is_action_pressed("interact") and player_in_range:
		is_holding = true
	elif event.is_action_released("interact"):
		is_holding = false
		hold_time = 0.0 # Reset the timer if they let go early

func _process(delta: float) -> void:
	if is_holding and player_in_range and has_monga:
		hold_time += delta
		
		# TODO: Add a visual indicator here. For example, you could slightly 
		# scale the sprite up or down based on (hold_time / required_hold_time)
		
		if hold_time >= required_hold_time:
			harvest_monga()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		is_holding = false
		hold_time = 0.0 # Crucial: Reset the timer if they run away

func harvest_monga() -> void:
	has_monga = false
	is_holding = false
	
	if resource_scene:
		var drop = resource_scene.instantiate()
		
		# Set to the MONGA enum
		drop.resource_type = ResourceDrop.RESOURCE_TYPE.MONGA
		
		drop.global_position = global_position + Vector2(0, 10)
		get_tree().current_scene.add_child(drop)

	# Remove the plant
	queue_free()
