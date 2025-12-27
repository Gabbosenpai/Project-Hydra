extends JsonSerializable
class_name SendAccountRecoveryEmailRequest

# User email address attached to their account
var Email: String

# The email template id of the account recovery email template to send.
var EmailTemplateId: String

# Unique identifier for the title, found in the Settings > Game Properties section of the PlayFab developer site when a title has been selected.
var TitleId: String


func _get_type_for_property(property_name: String) -> String:
	match property_name:
		"Email", "EmailTemplateId", "TitleId":
			return "String"
		_:
			push_error("Could not find mapping for property: " + property_name)
			return super._get_type_for_property(property_name)
	
