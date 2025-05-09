extends CharacterBody2D  # Il nemico è un corpo che può muoversi e interagire nella scena

#Variabili base del nemico
var velocita = 100  # Velocità di movimento orizzontale
var health_max = 5000  # Salute massima
var health_current = 5000  # Salute attuale

#Collegamenti ai nodi nella scena
@onready var barra = $Sprite2D/BarraSalute  # Barra della salute (ProgressBar)
@onready var area_rilevamento = $Area2D  # Area che rileva contatti con altri oggetti
@onready var collisione = $Area2D/CollisionShape2D  # Forma per rilevamento collisioni

#Valori dei danni
var danno_cannone_b = 40  # Danno da proiettile del cannone B
var danno_cannone_a = 20  # Danno da proiettile di altro tipo (es. cannone A)
var danno_alla_torre = 50  # Danno che il nemico infligge alla torre

#Variabili per gestire l'attacco alla torre
var attaccando_torre = false  # Se true, il nemico ha raggiunto una torre e smette di muoversi
var torre_target = null  # Riferimento alla torre da colpire
var tempo_attacco = 0.5  # Tempo tra un attacco e l’altro
var timer_attacco = 0.0  # Timer interno per gestire gli attacchi

func _ready() -> void:
	update_health_bar()  # Imposta la barra salute quando l’oggetto è pronto

func _process(delta: float) -> void:
	if health_current > 0:
		if not attaccando_torre:
			# Se non sta attaccando una torre, si muove verso sinistra
			position.x -= velocita * delta
			print("Posizione nemico aggiornata a:", position.x)
		else:
			# Se è in combattimento, gestisce il tempo tra un colpo e l’altro
			timer_attacco -= delta
			if timer_attacco <= 0.0 and torre_target:
				print("💥 Colpo alla torre!")
				# Verifica che la torre sia ancora valida e colpibile
				if is_instance_valid(torre_target) and torre_target.has_method("take_damage"):
					torre_target.take_damage(danno_alla_torre)
					timer_attacco = tempo_attacco  # Reset del timer
				else:
					# Se la torre è distrutta o non valida, torna a muoversi
					print("❌ Torre non più valida")
					attaccando_torre = false
					torre_target = null

#Aggiorna graficamente la barra della salute
func update_health_bar():
	barra.max_value = health_max
	barra.value = health_current
	print("Barra salute aggiornata. Salute: ", health_current)

#Quando il nemico riceve danno
func take_damage(danno: int):
	health_current -= danno
	update_health_bar()
	print("Il nemico ha ricevuto", danno, "danno. Salute rimanente:", health_current)

	if health_current <= 0:
		die()  # Se la salute finisce, muore

#Rimuove il nemico dalla scena
func die():
	print("☠️ Nemico eliminato. Salute a zero.")
	queue_free()

#Quando un corpo entra nell'Area2D del nemico
func _on_body_entered(body: Node) -> void:
	print("Corpo entrato nell'area di rilevamento:", body.name)

	# Se entra un proiettile, applica danno
	if body.is_in_group("Proiettile"):
		print("Proiettile rilevato! Infliggi danno.")
		
		# Danno differenziato a seconda del tipo di proiettile
		if body.has_method("get_cannon_type") and body.get_cannon_type() == "CannoneB":
			print("Proiettile del Cannone B rilevato! Infliggi danno maggiore.")
			take_damage(danno_cannone_b)
		else:
			take_damage(danno_cannone_a)

	# Se entra una torre, il nemico si ferma e comincia l'attacco
	elif body.is_in_group("Torre"):
		print("Torre rilevata! Fermati e inizia ad attaccare.")
		attaccando_torre = true
		torre_target = body
		timer_attacco = 0.0  # Parte subito l’attacco

#Quando un corpo esce dall’area di rilevamento
func _on_body_exited(body: Node) -> void:
	print("Corpo uscito dall'area di rilevamento:", body.name)
	
	if body.is_in_group("Proiettile"):
		print("Proiettile uscito dall'area.")  # Solo per debug
	elif body == torre_target:
		print("La torre è uscita dall'area.")
		attaccando_torre = false
		torre_target = null
