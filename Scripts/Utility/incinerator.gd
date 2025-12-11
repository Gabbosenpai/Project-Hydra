extends Node2D

@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var blast: AnimatedSprite2D = $Blast


func open_incinerator():
	# Assumendo che "open" sia la tua animazione di apertura
	animatedSprite.play("apertura") 
	await animatedSprite.animation_finished
	# Passa all'animazione di attesa
	animatedSprite.play("attesa") 


func fire_blast():
	blast.visible = true
	blast.play("blast")
	await blast.animation_finished


func close_incinerator():
	# Assumendo che "close" sia la tua animazione di chiusura
	animatedSprite.play("chiusura") 
	await animatedSprite.animation_finished
	# Rimuove l'istanza animata
	queue_free() 
