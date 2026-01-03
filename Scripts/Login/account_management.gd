extends Control

@onready var status_label = $PopupMenu/VBoxContainer/StatusLabel
@onready var confirmation_dialog = $ConfirmationDialog
@onready var popup_account = $PopupMenu

func _ready():
	# Connessione segnali di sicurezza
	if !PlayFabManager.client.api_error.is_connected(_on_api_error):
		PlayFabManager.client.api_error.connect(_on_api_error)
	if !PlayFabManager.client.account_removed.is_connected(_on_account_removed):
		PlayFabManager.client.account_removed.connect(_on_account_removed)

# --- RIMOZIONE ACCOUNT ---
# Collega questo al pulsante "Elimina Account"
func _on_remove_account_pressed() -> void:
	confirmation_dialog.popup_centered()

# Questo viene eseguito quando clicchi "OK" sul ConfirmationDialog
func _on_confirmation_dialog_confirmed() -> void:
	status_label.text = "Eliminazione in corso..."
	PlayFabManager.client.execute_cloud_script()

func _on_account_removed():
	status_label.text = "ACCOUNT ELIMINATO CON SUCCESSO"
	status_label.modulate = Color.GREEN
	
	# Pulizia sessione
	PlayFabManager.forget_login()
	
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")

# --- ERRORI ---
func _on_api_error(api_error_wrapper: ApiErrorWrapper):
	status_label.text = "Errore: " + api_error_wrapper.errorMessage
	status_label.modulate = Color.RED


func _on_logout_pressed() -> void:
	PlayFabManager.forget_login() # Rimuove i token di sessione
	get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")


func _on_back_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
