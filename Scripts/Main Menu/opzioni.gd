extends Control

#Riferimenti agli slider della musica e degli sfx e riferimento al pulsante indietro
@onready var music_slider = $MusicSlider
@onready var sfx_slider = $SfxSlider
@onready var back_button = $BackToMenuButton

#Funzione che inizializza le opzioni
func _ready():
	music_slider.value = AudioManager.music_volume * 100
	sfx_slider.value = AudioManager.sfx_volume * 100
	
	music_slider.connect("value_changed", Callable(self, "_on_music_slider_changed"))
	sfx_slider.connect("value_changed", Callable(self, "_on_sfx_slider_changed"))
	back_button.connect("pressed", Callable(self, "_on_back_pressed"))
	# 🔽 Sincronizza il testo del pulsante mute
	if AudioManager.is_music_muted:
		$MuteButton.text = "RIATTIVA AUDIO"
	else:
		$MuteButton.text = "DISATTIVA AUDIO"

#Funzione che cambia il volume della musica
func _on_music_slider_changed(value):
	AudioManager.set_music_volume(value / 100.0)

#Funzione che cambia il volume degli sfx
func _on_sfx_slider_changed(value):
	AudioManager.set_sfx_volume(value / 100.0)

#Funzione che consente di tornare alla scena precedente cioè il menu principale e che attiva l'sfx del pulsante indietro
func _on_back_pressed():
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")

#Funzione che consente di mutare l'audio
func _on_mute_button_pressed() -> void:
	AudioManager.toggle_music_mute()
	if AudioManager.is_music_muted:
		$MuteButton.text = "RIATTIVA AUDIO"
	else:
		$MuteButton.text = "DISATTIVA AUDIO"
