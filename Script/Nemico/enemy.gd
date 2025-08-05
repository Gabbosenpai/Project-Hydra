extends Node2D  # Estende Node2D, quindi questo script è per un nodo 2D generico (ad esempio un nemico)

signal enemy_defeated  # Segnale personalizzato che viene emesso quando il nemico muore

@export var health := 10  # Salute iniziale del nemico, modificabile dall'editor
var speed := 40          # Velocità di movimento del nemico in pixel al secondo


# Funzione chiamata ogni frame fisico (frame rate fisso)
func _physics_process(delta):
	# Sposta il nemico verso sinistra (diminuisce posizione x) in base alla velocità e al tempo delta
	position.x -= speed * delta

# Funzione per infliggere danno al nemico
func take_damage(damage: int) -> void:
	health -= damage  # Sottrae il danno alla salute attuale
	if health <= 0:   # Se la salute scende a zero o meno
		die()         # Chiama la funzione per la morte del nemico

# Funzione che controlla se il nemico è visibile nella viewport (schermo)
func is_on_screen() -> bool:
	# Usa il nodo figlio VisibleOnScreenNotifier2D per verificare la visibilità
	return $VisibleOnScreenNotifier2D.is_on_screen()

# Funzione chiamata quando il nemico deve morire
func die():
	emit_signal("enemy_defeated")  # Emette il segnale che avvisa che il nemico è stato sconfitto
	queue_free()                   # Rimuove e libera la memoria del nodo nemico dalla scena
