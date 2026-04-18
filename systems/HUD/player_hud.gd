extends CanvasLayer
class_name PlayerHUD

func _ready() -> void:
	# Keep your existing connection
	GameManager.inventory_updated.connect(update_ui)
	
	# Add the new Cauldron state connection
	GameManager.cauldron_state_updated.connect(update_progress_bars)
	
	update_ui()

func update_progress_bars() -> void:
	# Access them directly and apply the GameManager values
	$FuelProgress.value = GameManager.cauldron_fuel
	
	# Assuming BrewingProgress is a 0 to 100 scale. If it's 0 to 1, remove the * 100.0
	$BrewingProgress.value = GameManager.brew_progress * 100.0

func update_ui() -> void:
	# Update the text of each label, matching the order in your scene tree
	%label1.text = str(GameManager.ingredients["firewood"])
	%label2.text = str(GameManager.ingredients["sunfruit"])
	%label3.text = str(GameManager.ingredients["kookaberry"])
	%label4.text = str(GameManager.ingredients["spicetooth"])
	%label5.text = str(GameManager.ingredients["monga"])
