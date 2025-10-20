class_name MechaFreezer
extends Robot

@export var mf_max_health : int = 300
@export var mf_speed : float = 25
@export var mf_damage : int = 10

# Controllo se non sia in fase d'attacco tramite un controllo delle animazioni
# in questo modo sono sicuro che le faccia tutte prima di tornare a muoversi
func can_move():
	return !is_in_attack_phase() and !violence and current_health > 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Chiamo prima set_up e poi il ready della superclasse per evitare di
	# inizializzare un robot con valori nulli
	super.robot_set_up(mf_max_health, mf_speed, mf_damage)
	super._ready()

# Se il robot è in fase d'attacco, ovvero sta facendo certe animazioni, ritorna
# false, true se la sua attuale animazione è nella collezione sottostante
func is_in_attack_phase() -> bool:
	var attack_phases : Array = ["attack_end", "attack", "charge"]
	return robot_sprite.animation in attack_phases

# Congela la torretta rallentando il suo rateo di fuoco
func freeze_tower(tower: Node, duration: float, slow_factor: float = 2.0) -> void:
	if not tower or not is_instance_valid(tower):
		return
	
	# Riduci la velocità di fuoco della torretta (aumentando il reload time)
	var original_wait_time = tower.reloadTimer.wait_time
	tower.reloadTimer.wait_time *= slow_factor
	tower.towerSprite.modulate = Color(0.5, 0.8, 1.0) # effetto visivo azzurro

	print("Tower congelata! Reload aumentato da ", original_wait_time, " a ", tower.reloadTimer.wait_time)

	# Timer per ripristinare la torretta
	var timer = get_tree().create_timer(duration)
	await timer.timeout

	if is_instance_valid(tower):
		tower.reloadTimer.wait_time = original_wait_time
		tower.towerSprite.modulate = Color(1, 1, 1)
		print("Tower liberata!")

# Se il Robot ha una torretta davanti, inizia ad attaccare
func _on_tower_detector_area_entered(tower: Area2D) -> void:
	if tower.is_in_group("Tower"):
		violence = true
		target = tower
		robot_sprite.play("charge")
		await robot_sprite.animation_finished
		robot_sprite.play("attack")
		# Congela/rallenta la torretta per 3 secondi
		freeze_tower(tower, 3.0, 2.0)

# Quando finisce l'animazione d'attacco, facciamo un controllo sulla validità del 
# bersaglio: se true, il bersaglio subisce danno e il robot ricomincia l'animazione
# d'attacco
#Override
func _on_robot_sprite_animation_finished() -> void:
	var current_animation = robot_sprite.animation
	if current_animation == "attack" and violence and target and is_instance_valid(target):
		if target.has_method("take_damage"):
			target.take_damage(damage)
		robot_sprite.play("attack")
	elif current_animation == "attack" and !violence:
		robot_sprite.play("attack_end")
		await robot_sprite.animation_finished
		robot_sprite.play("move")
