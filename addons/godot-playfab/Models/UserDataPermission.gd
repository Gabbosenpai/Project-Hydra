extends JsonSerializable
class_name UserDataPermission

const PRIVATE = "Private"
const PUBLIC = "Public"
var value: String = PRIVATE





func _get_type_for_property(property_name: String) -> String:
	match property_name:
#		"<PROPERTY NAME>":
#			return "<PROPERTY TYPE>"
		_:
			pass
	
	push_error("Could not find mapping for property: " + property_name)
	return super._get_type_for_property(property_name)

func _init(v: String = PRIVATE):
	value = v

func _to_string():
	return value
