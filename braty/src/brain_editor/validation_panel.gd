class_name BrainEditorValidationPanel
extends RefCounted

const FeedbackMapperScript = preload("res://src/brain_editor/validation_feedback_mapper.gd")

var mapper

func _init(feedback_mapper = null) -> void:
	if feedback_mapper == null:
		mapper = FeedbackMapperScript.new()
	else:
		mapper = feedback_mapper

func summary_for_program(program: ProgramDefinition) -> Dictionary:
	var errors := ProgramValidator.validate(program)
	var messages: PackedStringArray = mapper.messages_for_errors(errors)
	return {
		"is_valid": errors.is_empty(),
		"errors": errors,
		"messages": messages,
	}
