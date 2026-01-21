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
		$StatusLabel.text = tr("username_too_short")
		$StatusLabel.modulate = Color.ORANGE
		return
		
	if not "@" in email or not "." in email:
		$StatusLabel.text = tr("email_not_valid")
		$StatusLabel.modulate = Color.ORANGE
		return
		
	if $Password.text.length() < 6:
		$StatusLabel.text = tr("password_too_short")
		$StatusLabel.modulate = Color.ORANGE
		return
	
	if username.length() > 20:
		$StatusLabel.text = tr("username_too_long")
		$StatusLabel.modulate = Color.ORANGE
		return

	var combined_info_request_params = GetPlayerCombinedInfoRequestParams.new()
	combined_info_request_params.show_all()
	var player_profile_view_constraints = PlayerProfileViewConstraints.new()
	combined_info_request_params.ProfileConstraints = player_profile_view_constraints
	#$Register.disabled = true
	$StatusLabel.text = tr("creating_account")
	$StatusLabel.modulate = Color.WHITE
	PlayFabManager.client.register_email_password(username, email, password, combined_info_request_params)

func _on_api_error(api_error_wrapper: ApiErrorWrapper):
	var key = "playfab_error_" + str(api_error_wrapper.errorCode)
	$StatusLabel.text = tr(key)
	$StatusLabel.modulate = Color.RED

func _on_registered(result: RegisterPlayFabUserResult):
	$StatusLabel.text = tr("registration_complete")
	$StatusLabel.modulate = Color.GREEN
	PlayFabManager.client_config.session_ticket = result.SessionTicket
	PlayFabManager.client_config.master_player_account_id = result.PlayFabId
	PlayFabManager.save_client_config()
	await get_tree().create_timer(2.0).timeout
	_on_back_to_login()

func _on_back_to_login():
	AudioManager.play_sfx(AudioManager.button_click_sfx)
	print("Registrazione e Email completate.")
	reset_fields_register()
	get_parent().get_parent().refresh_user_ui()
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
	get_parent().get_parent().refresh_user_ui()
	#get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")

func reset_fields_register():
	$Username.text = ""
	$Email.text = ""
	$Password.text = ""
	$StatusLabel.text = ""
	PlayFabManager.client_config.session_ticket = ""
