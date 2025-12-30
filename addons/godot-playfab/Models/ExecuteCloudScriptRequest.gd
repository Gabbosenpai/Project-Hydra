extends JsonSerializable
class_name ExecuteCloudScriptRequest

# The optional custom tags associated with the request (e.g. build number, external trace identifiers, etc.).
var CustomTags

# The name of the CloudScript function to execute
var FunctionName: String

# Object that is passed in to the function as the first argument
var FunctionParameter

# Generate a 'player_executed_cloudscript' PlayStream event containing the results of the function execution and other contextual information. This event will show up in the PlayStream debugger console for the player in Game Manager.
var GeneratePlayStreamEvent: bool

# Option for which revision of the CloudScript to execute. 'Latest' executes the most recently created revision, 'Live' executes the current live, published revision, and 'Specific' executes the specified revision. The default value is 'Specific', if the SpeificRevision parameter is specified, otherwise it is 'Live'.
var RevisionSelection: CloudScriptRevisionOption

# The specivic revision to execute, when RevisionSelection is set to 'Specific'
var SpecificRevision: int


func _get_type_for_property(property_name: String) -> String:
	match property_name:
		"RevisionSelection":
			return "CloudScriptRevisionOption"
		"CustomTags", "FunctionParameter":
			return "Dictionary"
		"FunctionName":
			return "String"
		"GeneratePlayStreamEvent":
			return "bool"
		"SpecificRevision":
			return "int"
		_:
			# Invece di push_error, deleghiamo al padre o torniamo vuoto
			return ""
	
