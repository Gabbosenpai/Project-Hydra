class_name WeedEater9000
extends Robot

@export var we9k_max_health : int = 75 
@export var we9k_speed : float = 100 
@export var we9k_damage : int = 2 
@export var block_chance : float = 0.33 # probabilità di bloccare (0.33 = 33%)
@export var we9k_max_points : int = 50 # ⬅️ NUOVO: Ad esempio, massimo 50 punti
@export var we9k_drop_chance : float = 0.5 # ⬅️ NUOVO: 50% di possibilità

var deflected : bool = false # Bool usata per fermare il robot al blocco

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Chiamo prima set_up e poi il ready della superclasse per evitare di
	# inizializzare un robot con valori nulli
	super.robot_set_up(we9k_max_health, we9k_speed, we9k_damage, we9k_max_points, we9k_drop_chance)
	super._ready()

# Un Weed Eater 9000 si ferma anche quando sta bloccando un proiettile 
func can_move() -> bool:
	return !violence and !deflected and current_health > 0

#Override
func take_damage(amount):
	if deflect():  
		amount = 0  # Setta il danno a zero, dando l'illusione di averlo bloccato
		robot_sprite.play("block")
		print("NO ONE CAN DEFLECT THE EMERLAD SPLASH!")
		await robot_sprite.animation_finished
	super.take_damage(amount)
	deflected = false

# Calcola con una randf se il robot riesce a bloccare il colpo 
# quando NON sta attaccando
func deflect() -> bool:
	if randf() < block_chance and !violence:
			deflected = true
			flash_blocked()
			return true
	return false

# Modula lo sprite per dare feedback visivo quando blocca con successo
func flash_blocked():
	modulate = Color(1, 1, 0) # giallo
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
