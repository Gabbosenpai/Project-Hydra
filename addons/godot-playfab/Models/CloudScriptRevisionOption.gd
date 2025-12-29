extends JsonSerializable
class_name CloudScriptRevisionOption

const LIVE = "Live"
const LATEST = "Latest"
const SPECIFIC = "Specific"
var value: String = LIVE


func _get_type_for_property(property_name: String) -> String:
	match property_name:
#		"<PROPERTY NAME>":
#			return "<PROPERTY TYPE>"
		_:
			pass
	
	push_error("Could not find mapping for property: " + property_name)
	return super._get_type_for_property(property_name)
	
func _init(v: String = LIVE):
	value = v

func _to_string():
	return value
