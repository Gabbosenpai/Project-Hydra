extends Area2D

# Variabili della Scrap     
@export var scrap_value: int = 50
@export var lifetime: float = 10.0   # tempo di vita in secondi
@export var hop_distance: Vector2 = Vector2(30, 40) # spostamento in basso a destra
@export var point_manager: Node # viene settato da chi spawna il rottame

@onready var lifetime_timer := Timer.new()

var scrap_sfx: AudioStream = preload("res://Assets/Sound/SFX/scrap.mp3") 

# Funzione che inizializza lo scrap e il suo timer affinche poi scompaia  
func _ready():
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))
	#print("Scrap ready at:", global_position, " z:", z_index)
	
	# Timer per far scomparire il rottame
	lifetime_timer.one_shot = true
	lifetime_timer.wait_time = lifetime
	add_child(lifetime_timer)
	lifetime_timer.start()
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	
	# Animazione spawn / hop
	play_spawn_animation()


# Funzione che cattura il clic del mouse e consente di prendere lo scrap   
func _on_input_event(_viewport, event, _shape_idx):
	if (
			event is InputEventMouseButton 
			and event.pressed 
			and event.button_index == MOUSE_BUTTON_LEFT
	):
		collect_scrap()
	if (
			event is InputEventScreenTouch 
			and event.pressed
	):
		collect_scrap()


# Funzione dopo il clic del mouse fa aumentare i punti 
# che si hanno per posizionare le torrette e poi dealloca la scrap
func collect_scrap():
	AudioManager.play_sfx(scrap_sfx)
	# Utilizziamo la funzione earn_points() del PointManager
	if point_manager and point_manager.has_method("earn_points"):
		# Assicurati che 'point_manager' sia un nodo che ha il metodo earn_points
		point_manager.earn_points(scrap_value)
		print("Scrap raccolto, punti guadagnati: ", scrap_value)
	queue_free()


# Funzione che dealloca la scrap a tempo scaduto se non si clicca su di essa
func _on_lifetime_timeout():
	# ASSEGNA I PUNTI PRIMA DI DEALLOCARE (Raccolta automatica per timeout)
	if point_manager and point_manager.has_method("earn_points"):
		# Invece di farla "sparire e basta", la consideriamo "raccolta automaticamente"
		point_manager.earn_points(scrap_value)
		print("Scrap scaduto, punti assegnati automaticamente: ", scrap_value)
	queue_free()


# Funzione che si occupa dell'animazione dello spawn della scrap
func play_spawn_animation():
	var tween = create_tween()
	
	# Decidi la direzione: 1 = destra, -1 = sinistra
	var direction = 1
	if randi() % 2 == 0:
		direction = -1
	
	# Calcola il bordo della pista come offset
	
	var hop_offset = Vector2(20 * direction, 15) # Piccolo spostamento verso dx/sx
	# Punto medio più alto per creare parabola
	var mid_pos = position + Vector2(hop_offset.x / 2, -20) 
	var target_pos = position + hop_offset
	
	# Tween lungo parabola: salita e discesa
	tween.tween_property(self, "position", mid_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Piccolo rimbalzo finale
	tween.tween_property(self, "position", target_pos + Vector2(0, -5), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
