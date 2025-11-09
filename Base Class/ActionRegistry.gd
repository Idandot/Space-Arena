extends Node

var actions: Dictionary = {}

func is_action_valid(action: Dictionary) -> bool:
	
	if !action.has("name"):
		push_error("Name your action! ", action)
		return false
	if typeof(action["name"]) != TYPE_STRING:
		push_error("Name your action properly! ", action)
		return false
	if !action.has("callback"):
		push_error("Give Callable to your action! ", action)
		return false
	if typeof(action["callback"]) != TYPE_CALLABLE:
		push_error("Give proper Callable to your action! ", action)
		return false
	
	return true

func standardize_action(action: Dictionary) -> Dictionary:
	var output_action = action.duplicate(true)
	
	if !action.has("type"):
		output_action["type"] = GlobalEnums.Actions.PASSIVE
	
	return output_action

func register_action(action: Dictionary):
	if is_action_valid(action):
		actions[action["name"]] = standardize_action(action)

func delete_action_by_dictionary(action: Dictionary):
	actions.erase(action["name"])

func delete_action(action_name: String):
	actions.erase(action_name)

func get_actions_by_type(type: int) -> Dictionary:
	var filtered_actions = {}
	for action in actions:
		if action.type == type:
			filtered_actions[action.name] = action
	return filtered_actions
















