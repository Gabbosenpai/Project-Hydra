extends Control

func _ready():
	var _error = PlayFabManager.client.connect("api_error",Callable(self,"_on_api_error"))
	_error = PlayFabManager.client.connect("logged_in",Callable(self,"_on_PlayFab_login_succeded"))

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
	get_tree().change_scene_to_file("res://Scenes/Utilities/menu.tscn")
	


func _on_register_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/Login/register.tscn")


func _on_forgot_password_button_up() -> void:
	var email = $Username.text
	PlayFabManager.client.send_account_recovery(email,"")
