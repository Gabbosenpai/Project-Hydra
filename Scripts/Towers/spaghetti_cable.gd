class_name SpaghettiCable
extends Area2D

# Segnali Custom
# Segnale di morte utilizzato per segnalare la morte della torretta 
# affinche la si possa rilevare ed eliminare dalle torrette presenti 
# evitando Null Pointer Exception
signal died(instance)

# % di riduzione danno
@export var dmg_reduction: float = 0.25
@export var max_health: float = 200

# Variabili di un torretta standard
var riga: int # Riga della torretta nella griglia, inizializzata al piazzamento
var tower_current_health: float
var turret_key: String = ""
var refund_percentage: float = 0.5
var scrap_scene: PackedScene = preload("res://Scenes/Utilities/Scrap.tscn")
var spaghettiCable_sfx: AudioStream = preload("res://Assets/Sound/SFX/spaghettiCable.mp3")
# Nodi-Figlio della scena
@onready var tower_sprite: AnimatedSprite2D = $TowerSprite
@onready var tower_hitbox: CollisionShape2D = $TowerHitbox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tower_current_health = max_health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	tower_sprite.play("idle")


#Funzione che fa prendere danno allo torretta
func take_damage(amount):
	#vita prima del danno subito
	var old_health := tower_current_health

	tower_current_health -= float(amount) * (1 - dmg_reduction)
	flash_bright()
	print("Tower HP:", tower_current_health)
	if tower_current_health < 0:
		tower_current_health = 0
	
	#quando la vita va sotto un multiplo di 20, riprdouci suono"
	if tower_current_health > 0 and int(old_health / 20) > int(tower_current_health / 20):
		AudioManager.play_sfx(spaghettiCable_sfx)
		
	if tower_current_health == 0:
		die()
		
#Funzione di morte per ora il nemico viene solamente deallocato dalla scena 
func die():
	emit_signal("died", self) 
	queue_free()


# Modula lo sprite per dare feedback visivo
func flash_bright():
	#AudioManager.play_sfx(spaghettiCable_sfx)
	tower_sprite.modulate = Color(1.3, 1.3, 1.3) # Più luminoso del normale
	await get_tree().create_timer(0.1).timeout
	tower_sprite.modulate = Color(1, 1, 1) # Normale


func set_riga(value: int) -> void:
	riga = value


func spawn_scrap_on_incinerate() -> void:
	# 1. Trova il PointManager
	var pm = get_tree().get_first_node_in_group("PointManager")
	
	if pm and scrap_scene and turret_key != "":
		var points_to_earn: int = pm.refund_points
		if points_to_earn > 0:
			var scrap_instance = scrap_scene.instantiate()
			var scrap_sprite = scrap_instance.get_node_or_null("Sprite2D")
			var scrap_collision = scrap_instance.get_node_or_null("CollisionShape2D")
			if scrap_sprite:
				scrap_sprite.scale = Vector2(1.5, 1.5)
				scrap_collision.scale = Vector2(2.0, 2.0)
					
				# Aggiungi al nodo genitore (Main/Level)
				get_parent().call_deferred("add_child", scrap_instance)
				
				# Assegna la posizione globale e i valori
				scrap_instance.global_position = global_position
				scrap_instance.scrap_value = points_to_earn
				scrap_instance.point_manager = pm
				scrap_instance.z_index = 100 
				
				print("Scrap Torretta (", points_to_earn, ") generato dall'inceneritore.")
