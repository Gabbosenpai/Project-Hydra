extends Node

var save_path := "user://save_data.save"
var max_unlocked_level := 1

func _ready():
	load_progress()

func unlock_level(level: int) -> void:
	if level > max_unlocked_level:
		max_unlocked_level = level
		save_progress()

func save_progress() -> void:
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		print("Errore nell'apertura del file in scrittura!")
		return
	file.store_var(max_unlocked_level)
	file.close()



func load_progress() -> void:
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



func get_max_unlocked_level() -> int:
	return max_unlocked_level

func reset_progress() -> void:
	max_unlocked_level = 1

	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open("user://")
		if dir and dir.file_exists("save_data.save"):
			var err = dir.remove("save_data.save")
			if err != OK:
				print("Errore durante la cancellazione del file di salvataggio: ", err)
	
	save_progress()
