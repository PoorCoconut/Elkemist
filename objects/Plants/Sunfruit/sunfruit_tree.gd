extends StaticBody2D
class_name SunfruitTree

@export_category("DROP SETTINGS")
@export var resource_scene: PackedScene

@onready var hurtbox: ComponentHurtbox = $HurtboxComponent

func _ready() -> void:
	if hurtbox:
		hurtbox.on_hit_received.connect(_on_dash_hit)

func _on_dash_hit(_knockback: float, direction: Vector2, attacker: Node2D) -> void:
	GameManager.do_camera_shake(2.0, 0.5)
	# 1. Spawn the fruit
	drop_fruit()
	
	# 2. Cancel the dash by bumping the player backward
	if attacker and attacker.has_method("apply_knockback"):
		# Reversing the direction sends the bump back toward the player
		var bounce_dir = -direction 
		
		# Apply a short, sharp knockback. Adjust 400.0 and 0.15 to change the feel
		attacker.apply_knockback(bounce_dir, 300.0, 0.15)
	
	# 3. Instantly remove the tree
	SoundBank.play_global_sfx("wood_gone")
	queue_free()

func drop_fruit() -> void:
	if resource_scene:
		var drop = resource_scene.instantiate()
		
		drop.resource_type = ResourceDrop.RESOURCE_TYPE.SUNFRUIT
		drop.global_position = global_position + Vector2(0, 15)
		
		# We must use call_deferred here to safely add the item, because 
		# we are deleting the tree in the exact same physics frame.
		get_tree().current_scene.call_deferred("add_child", drop)
