extends Node2D
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D

func open_incinerator():
	animatedSprite.play("apertura") # Assumendo che "open" sia la tua animazione di apertura
	await animatedSprite.animation_finished
	animatedSprite.play("attesa") # Passa all'animazione di attesa

func close_incinerator():
	animatedSprite.play("chiusura") # Assumendo che "close" sia la tua animazione di chiusura
	await animatedSprite.animation_finished
	queue_free() # Rimuove l'istanza animata
