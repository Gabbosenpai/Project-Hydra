extends Control

func _ready():
	var _error = PlayFabManager.client.connect("api_error",Callable(self,"_on_api_error"))
	_error = PlayFabManager.client.connect("logged_in",Callable(self,"_on_PlayFab_login_succeded"))
	_error = PlayFabManager.client.connect("account_removed", Callable(self, "_on_account_removed"))

func _on_login_button_up() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	$Login.disabled = true
	$StatusLabel.text = "Accesso in corso..."
	$StatusLabel.modulate = Color.WHITE
	var email = $Username.text
	var password = $Password.text
	var combined_info_request_params = GetPlayerCombinedInfoRequestParams.new()
	combined_info_request_params.show_all()
	var player_profile_view_constraints = PlayerProfileViewConstraints.new()
	combined_info_request_params.ProfileConstraints = player_profile_view_constraints
	PlayFabManager.client.login_with_email(email,password,{},combined_info_request_params)
	

func _on_api_error(api_error_wrapper: ApiErrorWrapper):
	$Login.disabled = false # Riabilita il tasto in caso di errore
	$StatusLabel.text = "Errore: " + api_error_wrapper.errorMessage
	$StatusLabel.modulate = Color.RED

func _on_PlayFab_login_succeded(login_result: LoginResult):
	$StatusLabel.text = "Login effettuato! Sincronizzazione..."
	$StatusLabel.modulate = Color.GREEN
	var account_info = login_result.InfoResultPayload.AccountInfo
	var user_name_found = ""
	
	if account_info:
		if account_info.TitleInfo.DisplayName:
			user_name_found = account_info.TitleInfo.DisplayName
		elif account_info.Username:
			user_name_found = account_info.Username
			
	# Salviamolo nella configurazione globale
	PlayFabManager.client_config.username = user_name_found
	PlayFabManager.client_config.email = $Username.text
	PlayFabManager.save_client_config() # Importante per persistenza
	
	print("Successo! Benvenuto: " + user_name_found)
	#print("Success ! " + str(login_result.InfoResultPayload.PlayerProfile))
	if not PlayFabManager.client.data_synchronized.is_connected(_on_data_ready):
		PlayFabManager.client.data_synchronized.connect(_on_data_ready)
	PlayFabManager.client.get_user_data()
	reset_fields_login()
	self.hide()
	get_parent().get_parent().toggle_main_options_ui(true)

func _on_data_ready():
	print("Dati sincronizzati correttamente. Benvenuto!")
	#get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")

func _on_register_button_up() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	self.hide()
	var register = get_parent().get_node("Register")
	register.reset_fields_register()
	register.visible = true
	#get_tree().change_scene_to_file("res://Scenes/Login/register.tscn")


func _on_back_main_menu_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	reset_fields_login()
	self.hide()
	get_parent().get_parent().toggle_main_options_ui(true)
	#get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")

func _on_forgot_password_pressed() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	var email = $Username.text
	if email != "":
		PlayFabManager.client.send_account_recovery(email, "")
		$StatusLabel.text = "Email inviata a: " + email
		$StatusLabel.modulate = Color.CYAN
	else:
		$StatusLabel.text = "Errore: Email mancante."
		$StatusLabel.modulate = Color.RED

func reset_fields_login():
	$Username.text = ""
	$Password.text = ""
	$StatusLabel.text = ""
	$Login.disabled = false
