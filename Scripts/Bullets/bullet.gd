@abstract
class_name Bullet
extends Area2D

# Nodi-Figlio della scena, inizializzati con onready perchè astratta
@onready var bullet_sprite : AnimatedSprite2D = $BulletSprite
@onready var bullet_hitbox : CollisionShape2D = $BulletHitbox
@onready var vis_on_screen_not : VisibleOnScreenNotifier2D = $VisNot 

# Variabili di un robot standard
var speed : float
var damage : int
var hit : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Inizializzo variabili per tutti i tipi di bullet
	hit = false
	# Connetto segnali
	vis_on_screen_not.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	self.area_entered.connect(_on_area_entered)

func bullet_set_up(bullet_speed : float, bullet_damage : int) -> void:
	speed = bullet_speed
	damage = bullet_damage

# Funzione chiamata ad ogni frame fisico (numero fisso di frame al secondo)
func _physics_process(delta):
	# Calcola il movimento in base alla direzione a destra, alla velocità e al tempo trascorso (delta)
	# Quando colpisce, si ferma -> l'animazione successiva non si muove
	if(!hit):
		var movement = Vector2.RIGHT * speed * delta
		bullet_sprite.play("travel")
		# Aggiorna la posizione globale del proiettile spostandolo in avanti
		global_position += movement

# Quando il nodo esce dallo schermo, deallocalo
func _on_visible_on_screen_notifier_2d_screen_exited():
	# Distrugge il nodo, liberando la memoria e rimuovendo il proiettile
	queue_free()

# Controlla se il proiettile è entrato nell'area del nemico
func _on_area_entered(area: Area2D):
	var enemy_node = area
	# Controlla se il nodo genitore appartiene al gruppo "Robot" e ha il metodo "take_damage"
	if enemy_node.is_in_group("Robot") and enemy_node.has_method("take_damage"):
		enemy_node.take_damage(damage) #Se nell'area fa danno al nemico
		# Dopo aver colpito il nemico, il proiettile si distrugge
		queue_free()
