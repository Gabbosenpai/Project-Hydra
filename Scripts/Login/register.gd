extends Control

func _ready():
	var _error = PlayFabManager.client.connect("api_error",Callable(self,"_on_api_error"))
	_error = PlayFabManager.client.connect("registered",Callable(self,"_on_registered"))

func _on_register_button_up() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	var username = $Username.text
	var email = $Email.text
	var password = $Password.text
	if username.length() < 3:
		$StatusLabel.text = "Username troppo corto\n(min 3 car.)"
		$StatusLabel.modulate = Color.ORANGE
		return
		
	if not "@" in email or not "." in email:
		$StatusLabel.text = "Email non valida!"
		$StatusLabel.modulate = Color.ORANGE
		return
		
	if $Password.text.length() < 6:
		$StatusLabel.text = "Password troppo corta\n(min 6 car)"
		$StatusLabel.modulate = Color.ORANGE
		return
	
	if username.length() > 20:
		$StatusLabel.text = "Username troppo lungo\n(max 20 car.)"
		$StatusLabel.modulate = Color.ORANGE
		return

	var combined_info_request_params = GetPlayerCombinedInfoRequestParams.new()
	combined_info_request_params.show_all()
	var player_profile_view_constraints = PlayerProfileViewConstraints.new()
	combined_info_request_params.ProfileConstraints = player_profile_view_constraints
	#$Register.disabled = true
	$StatusLabel.text = "Creazione account..."
	$StatusLabel.modulate = Color.WHITE
	PlayFabManager.client.register_email_password(username, email, password, combined_info_request_params)

func _on_api_error(api_error_wrapper: ApiErrorWrapper):
	var error_message = api_error_wrapper.errorMessage
	var details = ""
	
	# Estraiamo i dettagli specifici (es: "Password: Password is too short")
	if api_error_wrapper.errorDetails:
		for key in api_error_wrapper.errorDetails.keys():
			for msg in api_error_wrapper.errorDetails[key]:
				details += "\n- %s" % msg

	print("Errore PlayFab: " + error_message + details)
	
	if "display name" in error_message.to_lower() or "display name" in details.to_lower():
		error_message = "Username già esistente!"
		details = ""

	if has_node("EmailTag"):
		if details != "":
			$StatusLabel.text = "Dati non validi: " + details
		else:
			$StatusLabel.text = "Errore: " + error_message
		$StatusLabel.modulate = Color.RED

func _on_registered(result: RegisterPlayFabUserResult):
	$StatusLabel.text = "Registrazione completata"
	$StatusLabel.modulate = Color.GREEN
	PlayFabManager.client_config.session_ticket = result.SessionTicket
	PlayFabManager.client_config.master_player_account_id = result.PlayFabId
	PlayFabManager.save_client_config()

func _on_back_to_login():
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	print("Registrazione e Email completate.")
	reset_fields_register()
	
	self.hide()
	get_parent().get_node("Login").visible = true
	#get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")

func _on_back_button_up() -> void:
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	self.hide()
	var login = get_parent().get_node("Login")
	login.reset_fields_login()
	get_parent().get_node("Login").visible = true
	reset_fields_register()
	#get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")

func reset_fields_register():
	$Username.text = ""
	$Email.text = ""
	$Password.text = ""
	$StatusLabel.text = ""
