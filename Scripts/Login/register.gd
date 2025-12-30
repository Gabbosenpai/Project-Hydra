extends Control

func _ready():
	var _error = PlayFabManager.client.connect("api_error",Callable(self,"_on_api_error"))
	_error = PlayFabManager.client.connect("registered",Callable(self,"_on_registered"))

func _on_register_button_up() -> void:
	var username = $Username.text
	var email = $Email.text
	var password = $Password.text
	var combined_info_request_params = GetPlayerCombinedInfoRequestParams.new()
	combined_info_request_params.show_all()
	var player_profile_view_constraints = PlayerProfileViewConstraints.new()
	combined_info_request_params.ProfileConstraints = player_profile_view_constraints
	PlayFabManager.client.register_email_password(username, email, password, combined_info_request_params)

func _on_api_error(api_error_wrapper: ApiErrorWrapper):
	var error_message = api_error_wrapper.errorMessage
	print("Errore PlayFab: " + error_message)

	# Usiamo EmailTag per mostrare l'errore se non vuoi aggiungere StatusLabel
	if has_node("EmailTag"):
		if "Email address not available" in error_message:
			$EmailTag.text = "ERRORE: Email già in uso!"
			$EmailTag.modulate = Color.RED
		else:
			$EmailTag.text = "Errore registrazione."
			$EmailTag.modulate = Color.RED

	# Coloriamo il tasto Register di rosso per feedback visivo
	if has_node("Register"):
		$Register.self_modulate = Color(1, 0, 0, 0.5)

func _on_registered(result: RegisterPlayFabUserResult):
	$Register.self_modulate = Color(0, 1, 0, 0.5)
	print("[color=green]Registration for \"%s\" succeeded!" % result.Username)
	PlayFabManager.client_config.session_ticket = result.SessionTicket
	PlayFabManager.client_config.master_player_account_id = result.PlayFabId
	PlayFabManager.save_client_config()

func _on_back_to_login():
	print("Registrazione e Email completate.")
	get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")

func _on_back_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")
