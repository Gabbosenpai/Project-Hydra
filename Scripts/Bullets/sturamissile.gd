class_name Sturamissile
extends Bullet

@export var sturamissile_speed: float = 200 # Velocità del proiettile
@export var sturamissile_damage: int = 10 # Danno del proiettile

var armed: bool

func _ready() -> void:
	super.bullet_set_up(sturamissile_speed, sturamissile_damage)
	super._ready()
	armed = false
	#var current_height = get
	var tween1 = create_tween()
	tween1.parallel().tween_property(self, "rotation_degrees", 90, 0.4)
	#tween.parallel().tween_property(self, "position:y", global_position.y + 15, 0.5)
	var timer = get_tree().create_timer(0.5)
	await timer.timeout
	tween1.kill()
	var tween2 = create_tween()
	tween2.tween_property(self, "rotation_degrees", 0, 0.0)
	bullet_sprite.play("travel")
	armed = true


# Override
# Funzione chiamata ad ogni frame fisico (numero fisso di frame al secondo)
func _physics_process(delta):
	# Calcola il movimento in base alla direzione a destra, alla velocità e al tempo trascorso (delta)
	# Quando colpisce, si ferma -> l'animazione successiva non si muove
	if(!hit and armed):
		var movement = Vector2.RIGHT * speed * delta
		bullet_sprite.play("travel")
		# Aggiorna la posizione globale del proiettile spostandolo in avanti
		global_position += movement
