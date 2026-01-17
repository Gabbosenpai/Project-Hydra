extends Control
@onready var user = $User
@onready var status_label = $UserLabel
@onready var confirmPanel = $ConfirmPanel

func _ready():
	# Connessione segnali di sicurezza
	if !PlayFabManager.client.api_error.is_connected(_on_api_error):
		PlayFabManager.client.api_error.connect(_on_api_error)
	if !PlayFabManager.client.account_removed.is_connected(_on_account_removed):
		PlayFabManager.client.account_removed.connect(_on_account_removed)

# --- RIMOZIONE ACCOUNT ---
# Collega questo al pulsante "Elimina Account"
func _on_remove_account_pressed() -> void:
	confirmPanel.visible = true
	user.visible = false

func _on_account_removed():
	status_label.text = "ACCOUNT ELIMINATO CON SUCCESSO"
	status_label.modulate = Color.GREEN
	
	# Pulizia sessione
	PlayFabManager.forget_login()
	
	await get_tree().create_timer(2.0).timeout
	self.hide()
	get_parent().get_node("Login").visible = true
	reset_label_()
	get_parent().get_parent().refresh_user_ui()
	#get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")

# --- ERRORI ---
func _on_api_error(api_error_wrapper: ApiErrorWrapper):
	status_label.text = "Errore: " + api_error_wrapper.errorMessage
	status_label.modulate = Color.RED


func _on_logout_pressed() -> void:
	PlayFabManager.forget_login() # Rimuove i token di sessione
	self.hide()
	get_parent().get_parent().toggle_main_options_ui(true)
	reset_label_()
	get_parent().get_parent().refresh_user_ui()
	#get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")


func _on_back_main_menu_pressed() -> void:
	self.hide()
	get_parent().get_parent().toggle_main_options_ui(true)
	reset_label_()
	get_parent().get_parent().refresh_user_ui()
	#get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")

func reset_label_():
	status_label.text = PlayFabManager.client_config.username
	status_label.modulate = Color.WHITE


func _on_yes_button_pressed() -> void:
	status_label.text = "Eliminazione in corso..."
	PlayFabManager.client.execute_cloud_script()


func _on_no_button_pressed() -> void:
	confirmPanel.visible = false
	user.visible = true
