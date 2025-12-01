class_name CoffeeBullet
extends Bullet  

# Variabili esportate per poterle modificare facilmente dall'editor di Godot
@export var coffee_bullet_speed: float = 200  # Velocità proiettile
@export var coffee_bullet_damage: int = 50 # Danno proiettile
@export var coffee_duration = 10.0


func _ready() -> void:
	super.bullet_set_up(coffee_bullet_speed, coffee_bullet_damage)
	super._ready()


# Funzione chiamata quando questo Area2D entra in collisione con un altro Area2D
func _on_area_entered(area: Area2D):
	# Ottiene il nodo genitore dell'area entrata in collisione (di solito l'enemy)
	var enemy_node = area
	# Controlla se il nodo genitore appartiene al gruppo "Robot" e ha il metodo "take_damage"
	if enemy_node.is_in_group("Robot") and enemy_node.has_method("take_damage"):
		# Chiama la funzione take_damage sull'enemy, passando il valore del danno del proiettile
		hit = true
		# Se il robot ha il metodo burning_coffee_DOT, lo chiamiamo
		if enemy_node.has_method("burning_coffee_DOT"):
			enemy_node.burning_coffee_DOT(coffee_bullet_damage, coffee_duration)
		bullet_sprite.play("explosion")


func _on_bullet_sprite_animation_finished() -> void:
	var current_animation = bullet_sprite.animation
	if (current_animation == "explosion"):
		queue_free()
