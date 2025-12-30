extends Node

# Creo il current_slot e lo inizializzo a 1 (poteva essere anche 2 o 3)
var current_slot = 1  
# Per contenere l'ultimo livello sbloccato
var max_unlocked_level = 1


# Funzione che si occupa di caricare i dati salvati
func _ready():
	load_progress()


# Funzione che si occupa di sbloccare il livello successivo e salva i progressi
func unlock_level(level: int) -> void:
	if level > max_unlocked_level:
		max_unlocked_level = level
		save_progress()

func save_local_only() -> void:
	var save_path = "user://save_slot_%d.save" % current_slot
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		print("Errore nell'apertura del file in scrittura!")
		return
	file.store_var(max_unlocked_level)
	file.close()

# Funzione che si occupa salvare i dati
func save_progress() -> void:
	save_local_only()
	if PlayFabManager.client_config.is_logged_in():
		PlayFabManager.client.update_user_data()


# Passo il numero dello slot e restituisce se il path esiste o no
func has_save(slot) -> bool:
	var save_path = "user://save_slot_%d.save" % slot
	return FileAccess.file_exists(save_path)


# Per capire qual è l'ultimo livello fatto
# 0 indica VUOTO, altrimenti 
func get_saved_level(slot) -> int:
	var save_path = "user://save_slot_%d.save" % slot
	if !FileAccess.file_exists(save_path):
		return 0  # 0 indica "vuoto"
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return 0
	
	# Recupero l'ultimo livello completato
	var level = file.get_var()
	file.close()
	return level


# Funzione che si occupa caricare i progressi
func load_progress() -> void:
	var save_path = "user://save_slot_%d.save" % current_slot
	if !FileAccess.file_exists(save_path):
		max_unlocked_level = 1
		return
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		print("Errore nell'apertura del file in lettura!")
		max_unlocked_level = 1
		return
	max_unlocked_level = file.get_var()
	file.close()


# Funzione che restituisce il livello massimo sbloccato 
func get_max_unlocked_level() -> int:
	return max_unlocked_level


# Funzione che restituisce resetta i progressi 
# e imposta il massimo livello sbloccato a quello iniziale
func reset_progress() -> void:
	# Sostituisci il valore di current_slot nel %d
	var save_path = "user://save_slot_%d.save" % current_slot
	
	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open("user://")
		if dir and dir.file_exists(save_path.get_file()):
			var err = dir.remove(save_path.get_file())
			# OK è il "valore" restituito da remove in caso di rimozione con successo
			if err != OK:
				print("Errore durante la cancellazione del file di salvataggio: ", err)
	# Cancella anche i punti del Tech Tree per lo slot corrente
	var tech_tree_path = "user://tech_tree_slot_%d.save" % current_slot
	if FileAccess.file_exists(tech_tree_path):
		var dir2 = DirAccess.open("user://")
		if dir2 and dir2.file_exists(tech_tree_path.get_file()):
			var err2 = dir2.remove(tech_tree_path.get_file())
			if err2 != OK:
				print("Errore durante la cancellazione dei punti TechTree: ", err2)
	
	# Reset dati
	max_unlocked_level = 1
	save_progress()



# Restituisce il massimo livello sbloccato tra tutti e tre gli slot

func get_max_level_all_slots() -> int:
	var max_level = 0
	for slot in range(1, 4):  # range(inizio, fine) esclusivo della fine
		var level = get_saved_level(slot)
		if level > max_level:
			max_level = level
	return max_level
