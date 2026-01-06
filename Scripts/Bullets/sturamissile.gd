class_name Sturamissile
extends Bullet

@export var sturamissile_speed: float = 350 # Velocità del proiettile
@export var sturamissile_damage: int = 42 # Danno del proiettile
var sturamissile_sfx: AudioStream = preload("res://Assets/Sound/SFX/sturamissile_explosion.mp3")
var armed: bool
var explosion_range: Array

@onready var explosion_blast: Area2D = $ExplosionBlast


func _ready() -> void:
	super.bullet_set_up(sturamissile_speed, sturamissile_damage)
	super._ready()
	bullet_hitbox.disabled = true
	explosion_blast.area_entered.connect(_on_explosion_blast_area_entered)
	armed = false
	var tween1 = create_tween()
	tween1.parallel().tween_property(self, "rotation_degrees", 90, 0.5)
	var timer = get_tree().create_timer(0.5)
	await timer.timeout
	tween1.kill()
	var tween2 = create_tween()
	tween2.tween_property(self, "rotation_degrees", 0, 0.0)
	bullet_sprite.play("travel")
	armed = true
	bullet_hitbox.disabled = false


# Override
# Funzione chiamata ad ogni frame fisico (numero fisso di frame al secondo)
func _physics_process(delta):
	if(!armed):
		var jump = Vector2.UP * 80.0 * delta
		global_position += jump
	if(!hit and armed):
		var movement = Vector2(1,1) * Vector2(speed, 5) * delta
		bullet_sprite.play("travel")
		# Aggiorna la posizione globale del proiettile spostandolo in avanti
		global_position += movement


func explode() -> void:
	for robot in explosion_range:
		if (
				robot != null 
				and is_instance_valid(robot) 
				and robot.has_method("take_damage")
		):
			AudioManager.play_sfx(sturamissile_sfx)
			robot.take_damage(damage)


# Override
# Controlla se il proiettile è entrato nell'area del nemico
func _on_area_entered(robot: Area2D):
	if robot.is_in_group("Robot"):
		if(!hit):
			hit = true
			explode()
			bullet_sprite.play("explosion")


func _on_explosion_blast_area_entered(robot: Area2D):
	if robot.is_in_group("Robot"):
		explosion_range.append(robot)
