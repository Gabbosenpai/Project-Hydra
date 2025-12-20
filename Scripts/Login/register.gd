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
	var text = "[b]%s[/b]\n\n" % api_error_wrapper.errorMessage
	var error_details = api_error_wrapper.errorDetails

	if error_details:
		for key in error_details.keys():
			text += "[color=red][b]%s[/b][/color]: " % key
			for element in error_details[key]:
				text += "%s\n" % element

	print(str(text))
	$Register.self_modulate = Color(1, 0, 0, 0.5)

func _on_registered(result: RegisterPlayFabUserResult):
	$Register.self_modulate = Color(0, 1, 0, 0.5)
	print("[color=green]Registration for \"%s\" succeeded!" % result.Username)

func _on_back_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Login/login.tscn")
