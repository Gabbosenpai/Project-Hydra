extends JsonSerializable
class_name UpdateUserDataRequest

#The optional custom tags associated with the request (e.g. build number, external trace identifiers, etc.).
var CustomTags: Object


# Key-value pairs to be written to the custom data. Note that keys are trimmed of whitespace, are limited in size, and may not begin with a '!' character or be null.
var Data: Object

# Optional list of Data-keys to remove from UserData. Some SDKs cannot insert null-values into Data due to language constraints. Use this to delete the keys directly.
var KeysToRemove: Array

# Permission to be applied to all user data keys written in this request. Defaults to "private" if not set.
var Permission: UserDataPermission

# Unique PlayFab assigned ID of the user on whom the operation will be performed.
var PlayFabId: String


func _get_type_for_property(property_name: String) -> String:
	match property_name:
		"Data":
			return "Dictionary" 
		"CustomTags":
			return "Dictionary"
		"KeysToRemove":
			return "Array"
		"Permission":
			return "UserDataPermission"
		"PlayFabId":
			return "String"
	
	return super._get_type_for_property(property_name)
	
