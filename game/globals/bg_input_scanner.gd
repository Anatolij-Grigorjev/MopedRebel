extends Node

const SCANNED_ACTIONS_NAMES = [
	"walk_up",
	"walk_down"
]

var input_action_states = {}


func reset_actions_states():
	input_action_states.clear()
	for action_name in SCANNED_ACTIONS_NAMES:
		input_action_states[action_name] = new_action_state()

func is_action_just_pressed(action_name):
	validate_action_name(action_name)
	return input_action_states[action_name].just_pressed
	
func is_action_just_released(action_name):
	validate_action_name(action_name)
	return input_action_states[action_name].just_released

func is_action_pressed(action_name):
	validate_action_name(action_name)
	return input_action_states[action_name].pressed
	
func is_action_released(action_name):
	validate_action_name(action_name)
	return input_action_states[action_name].released


func _ready():
	reset_actions_states()
	print("Loaded global BG Input scanner IO!")
	pass
	
func _unhandled_input(event):
	for action_name in SCANNED_ACTIONS_NAMES:
		if (event.is_action(action_name)):
			handle_action_event(action_name, event)
			
func handle_action_event(action_name, input_event):
	var action_state_obj = input_action_states[action_name]
	var action_released = input_event.is_action_released(action_name)
	var action_pressed = input_event.is_action_pressed(action_name)

	action_state_obj.just_pressed = action_state_obj.released && action_pressed
	action_state_obj.just_released = action_state_obj.pressed && action_released
	action_state_obj.released = action_released
	action_state_obj.pressed = action_pressed
	

func validate_action_name(action_name):
	if not (action_name in SCANNED_ACTIONS_NAMES):
		F.log_error("%s is not a scanned action!", [action_name])
	
func new_action_state():
	return {
		'released': true,
		'pressed': false,
		'just_pressed': false,
		'just_released': false
	}
