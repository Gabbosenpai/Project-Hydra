extends Control

func _ready():
	var _error = PlayFabManager.client.connect("api_error",Callable(self,"_on_api_error"))
	_error = PlayFabManager.client.connect("logged_in",Callable(self,"_on_PlayFab_login_succeded"))
	_error = PlayFabManager.client.connect("account_removed", Callable(self, "_on_account_removed"))

func _on_login_button_up() -> void:
	var email = $Username.text
	var password = $Password.text
	var combined_info_request_params = GetPlayerCombinedInfoRequestParams.new()
	combined_info_request_params.show_all()
	var player_profile_view_constraints = PlayerProfileViewConstraints.new()
	combined_info_request_params.ProfileConstraints = player_profile_view_constraints
	PlayFabManager.client.login_with_email(email,password,{},combined_info_request_params)

func _on_api_error(api_error_wrapper: ApiErrorWrapper):
	var text = "[b]%s[/b]\n\n" % api_error_wrapper.errorMessage
	var error_details = api_error_wrapper.errorDetails

	if error_details:
		for key in error_details.keys():
			text += "[color=red][b]%s[/b][/color]: " % key
			for element in error_details[key]:
				text += "%s\n" % element
	print(str(text))

func _on_PlayFab_login_succeded(login_result: LoginResult):
	print("Success ! " + str(login_result.InfoResultPayload.PlayerProfile))
	if not PlayFabManager.client.data_synchronized.is_connected(_on_data_ready):
		PlayFabManager.client.data_synchronized.connect(_on_data_ready)
	PlayFabManager.client.get_user_data()

func _on_data_ready():
	print("Dati sincronizzati correttamente. Benvenuto!")
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")

func _on_account_removed():
	print("UI: Ricevuta conferma rimozione account.")
	$ConfirmationDialog.visible = false
	
	
	$EmailTag.text = "ACCOUNT ELIMINATO CON SUCCESSO"
	$EmailTag.modulate = Color.GREEN # Cambia il colore in verde
	
	
	$Login.disabled = true
	$RemoveAccount.disabled = true
	
	# Aspettiamo 2 secondi per mostrare il colore verde
	await get_tree().create_timer(2.0).timeout
	
	# Torniamo alla scena di login (o resettiamo la scena attuale)
	get_tree().reload_current_scene()

func _on_register_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Login/register.tscn")


func _on_forgot_password_button_up() -> void:
	var email = $Username.text
	PlayFabManager.client.send_account_recovery(email,"")


func _on_remove_account_button_up() -> void:
	var confirmationDialog = $ConfirmationDialog
	confirmationDialog.visible = true



func _on_confirmation_dialog_confirmed() -> void:
	PlayFabManager.client.execute_cloud_script();


func _on_confirmation_dialog_canceled() -> void:
	var confirmationDialog = $ConfirmationDialog
	confirmationDialog.visible = false
