extends StaticBody2D
class_name FirewoodTree

@export_category("DROP SETTINGS")
@export var resource_scene: PackedScene

@onready var hurtbox: ComponentHurtbox = $HurtboxComponent

func _ready() -> void:
	if hurtbox:
		hurtbox.on_hit_received.connect(_on_dash_hit)

func _on_dash_hit(_knockback: float, direction: Vector2, attacker: Node2D) -> void:
	GameManager.do_camera_shake(2.0, 0.5)
	# 1. Spawn the firewood
	drop_wood()
	
	# 2. Cancel the dash by bumping the player backward
	if attacker and attacker.has_method("apply_knockback"):
		var bounce_dir = -direction 
		# Keeping the force and duration identical to the Sunfruit tree
		attacker.apply_knockback(bounce_dir, 300.0, 0.15)
	
	# 3. Instantly remove the tree
	SoundBank.play_global_sfx("wood_gone")
	queue_free()

func drop_wood() -> void:
	if resource_scene:
		
		var drop = resource_scene.instantiate()
		
		# Set the enum specifically to FIREWOOD
		drop.resource_type = ResourceDrop.RESOURCE_TYPE.FIREWOOD
		drop.global_position = global_position + Vector2(0, 15)
		
		# Safely add the item to the world tree
		get_tree().current_scene.call_deferred("add_child", drop)
