extends StaticBody2D
class_name KookaberryBush

@export_category("DROP SETTINGS")
@export var resource_scene: PackedScene
@export var clicks_required: int = 5

var current_clicks: int = 0
var player_in_range: bool = false
var has_berries: bool = true

func _ready() -> void:
	# Connect the Area2D signals directly
	var interaction_area = $InteractionArea
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

# Using unhandled_input prevents clicks from passing through UI menus
func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and has_berries:
		if event.is_action_pressed("interact"):
			current_clicks += 1
			
			# TODO: Add a slight rotation or scale tween here to visually show the bush rustling
			
			if current_clicks >= clicks_required:
				drop_berries()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		current_clicks = 0

func drop_berries() -> void:
	has_berries = false
	
	if resource_scene:
		var drop = resource_scene.instantiate()
		
		# Set to KOOKABERRY enum
		drop.resource_type = ResourceDrop.RESOURCE_TYPE.KOOKABERRY
		
		drop.global_position = global_position + Vector2(0, 10)
		get_tree().current_scene.add_child(drop)

	# Remove the bush from the arena
	queue_free()
