extends CharacterBody2D

# Velocità del proiettile in pixel al secondo
var velocita = 300

# Direzione verso cui si muove il proiettile (in questo caso verso destra)
var velocitaVettore = Vector2.RIGHT  # Vector2(1, 0)

func _physics_process(delta: float) -> void:
	# Muove il proiettile e rileva eventuali collisioni lungo il percorso
	var infoCollisione = move_and_collide(velocitaVettore * velocita * delta)

	# Se il proiettile collide con qualcosa
	if infoCollisione:
		var corpo = infoCollisione.get_collider()

		# Stampa il nome del corpo con cui ha colliso (utile per il debug)
		print("Proiettile ha colliso con:", corpo.name)

		# Se il corpo fa parte del gruppo "Nemico"
		if corpo.is_in_group("Nemico"):
			print("Proiettile ha colpito un nemico!")

			# Se il nemico ha il metodo 'take_damage', allora infliggi danno
			if corpo.has_method("take_damage"):
				corpo.take_damage(20)  # Infliggi 20 punti di danno
				print("Danno inflitto al nemico.")

		# Indipendentemente dal tipo di collisione, distruggi il proiettile
		queue_free()
		print("Proiettile distrutto dopo la collisione.")
