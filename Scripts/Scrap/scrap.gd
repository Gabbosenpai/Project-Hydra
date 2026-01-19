extends Area2D

# Variabili della Scrap     
@export var scrap_value: int = 50
@export var lifetime: float = 10.0   # tempo di vita in secondi
@export var lampeggiante: float = 7   # Quanto tempo lampeggia
@export var hop_distance: Vector2 = Vector2(20, 15) # spostamento in basso a destra
@export var incinerator_distance: Vector2 = Vector2(20, 15) # spostamento in basso a destra
@export var point_manager: Node # viene settato da chi spawna il rottame

@onready var lifetime_timer: Timer = $Lifetime
@onready var lampeggiante_timer: Timer = $Lampeggiante


var scrap_sfx: AudioStream = preload("res://Assets/Sound/SFX/scrap.mp3") 

# Funzione che inizializza lo scrap e il suo timer affinche poi scompaia  
func _ready():
	input_pickable = true
	connect("input_event", Callable(self, "_on_input_event"))
	#print("Scrap ready at:", global_position, " z:", z_index)
	# Timer per far scomparire il rottame
	lifetime_timer.wait_time = lifetime
	lampeggiante_timer.wait_time = lampeggiante
	lifetime_timer.start()
	lampeggiante_timer.start()
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	lampeggiante_timer.timeout.connect(_on_lampeggiante_timeout)
	
	# Animazione spawn / hop
	if scrap_value >= 50:
		play_spawn_animation()
	else:
		play_incinerator_spawn_animation()


# Funzione che cattura il clic del mouse e consente di prendere lo scrap   
func _on_input_event(_viewport, event, _shape_idx):
	var should_I_earn: bool = false
	if (
			event is InputEventMouseButton 
			and event.pressed 
			and event.button_index == MOUSE_BUTTON_LEFT
	):
		should_I_earn = true
	if (
			event is InputEventScreenTouch 
			and event.pressed
	):
		should_I_earn = true
	if should_I_earn:
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


# Funzione che dealloca la scrap a tempo scaduto se non si clicca su di esso
func _on_lifetime_timeout():
	# NON ASSEGNARE I PUNTI 
	if point_manager and point_manager.has_method("earn_points"):
		# Scrap scade, punti non assegnati
		print("Scrap scaduto, punti PERSI: ", scrap_value)
	queue_free()


# Scrap segnala che deve iniziare a lampeggiare perchè sta per scomparire
func _on_lampeggiante_timeout():
	if has_method("lampeggia"):
		lampeggia()


# Fa lampeggiare lo scrap: sta per scomparire
func lampeggia():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	tween.tween_property(self, "modulate:a", 1.0, 0.25)


# Funzione che si occupa dell'animazione dello spawn della scrap
func play_spawn_animation():
	var tween = create_tween()
	
	# Decidi la direzione: 1 = destra, -1 = sinistra
	var direction = 1
	if randi() % 2 == 0:
		direction = -1
	
	# Calcola il bordo della pista come offset
	
	var hop_offset = Vector2(hop_distance.x * direction, hop_distance.y) # Piccolo spostamento verso dx/sx
	# Punto medio più alto per creare parabola
	var mid_pos = position + Vector2(hop_offset.x / 2, hop_offset.y - 35) 
	var target_pos = position + hop_offset
	
	# Tween lungo parabola: salita e discesa
	tween.tween_property(self, "position", mid_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Piccolo rimbalzo finale
	tween.tween_property(self, "position", target_pos + Vector2(0, -5), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func play_incinerator_spawn_animation():
	var tween = create_tween()
	
	# Punto medio più alto per creare parabola
	var mid_pos = position + Vector2(incinerator_distance.x / 2, incinerator_distance.y - 75) 
	var target_pos = position + incinerator_distance
	
	# Tween lungo parabola: salita e discesa
	tween.tween_property(self, "position", mid_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Piccolo rimbalzo finale
	tween.tween_property(self, "position", target_pos + Vector2(0, -5), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
