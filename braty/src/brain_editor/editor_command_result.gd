class_name BrainEditorCommandResult
extends RefCounted

var is_success: bool
var value: Variant
var error_code: int
var connection_error: int

func _init(
	result_is_success: bool,
	result_value: Variant = null,
	result_error_code: int = 0,
	result_connection_error: int = -1
) -> void:
	is_success = result_is_success
	value = result_value
	error_code = result_error_code
	connection_error = result_connection_error
