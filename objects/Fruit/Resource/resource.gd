extends Area2D
class_name ResourceDrop

enum RESOURCE_TYPE {
	SUNFRUIT,
	KOOKABERRY,
	SPICETOOTH,
	MONGA,
	FIREWOOD 
}

@export var resource_type : RESOURCE_TYPE = RESOURCE_TYPE.SUNFRUIT
@export var magnet_speed : float = 250.0

var is_magnetized : bool = false
var target : CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.frame = resource_type
	
	# Start the despawn timer immediately upon creation
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _process(delta: float) -> void:
	if is_magnetized and target:
		var item_name = get_string_from_enum()
		
		# Only move toward the player if they actually have room for it
		if GameManager.ingredients[item_name] < GameManager.MAX_INGREDIENT_CAP:
			global_position = global_position.move_toward(target.global_position, magnet_speed * delta)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var item_string = get_string_from_enum()
		var picked_up = GameManager.add_ingredient(item_string, 1)
		
		if picked_up:
			queue_free()

func _on_magnet_area_body_entered(body: Node2D) -> void:
	if body is Player:
		is_magnetized = true
		target = body

func _on_magnet_area_body_exited(body: Node2D) -> void:
	if body is Player:
		is_magnetized = false
		target = null

func get_string_from_enum() -> String:
	match resource_type:
		RESOURCE_TYPE.SUNFRUIT: return "sunfruit"
		RESOURCE_TYPE.KOOKABERRY: return "kookaberry"
		RESOURCE_TYPE.SPICETOOTH: return "spicetooth"
		RESOURCE_TYPE.MONGA: return "monga"
		RESOURCE_TYPE.FIREWOOD: return "firewood"
	return ""
