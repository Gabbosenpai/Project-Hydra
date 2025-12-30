extends JsonSerializable
class_name GetUserDataRequest

# The version that currently exists according to the caller. The call will return the data for all of the keys if the version in the system is greater than this.
var IfChangedFromDataVersion: int

# List of unique keys to load from.
var Keys: Array

# Unique PlayFab identifier of the user to load data for. Optional, defaults to yourself if not set. When specified to a PlayFab id of another player, then this will only return public keys for that account.
var PlayFabId: String


func _get_type_for_property(property_name: String) -> String:
	match property_name:
#		"<PROPERTY NAME>":
#			return "<PROPERTY TYPE>"
		_:
			pass
	
	push_error("Could not find mapping for property: " + property_name)
	return super._get_type_for_property(property_name)
	
