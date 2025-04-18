extends Node2D

@onready var enemy_scene = preload("res://enemy.tscn")  # Carica la scena del nemico
@onready var score_label = $CanvasLayer/ScoreLabel  # Riferimento al punteggio (assicurati che il percorso sia corretto)
@onready var ost_player = $OST 
var score: int = 0

func _ready():
	ost_player.play()
	$EnemyTimer.start()  # Avvia il timer per spawnare nemici
	$ScoreTimer.start()  # Avvia il timer per il punteggio

func _on_EnemyTimer_timeout():
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector2(800, randf_range(100, 500))  # Posizione random per il nemico
	add_child(enemy)


	


func _on_score_timer_timeout() -> void:
	
	score += 1
	Globals.score = score  # 🔥 salva il punteggio globale
	score_label.text = "Score: %d" % score
