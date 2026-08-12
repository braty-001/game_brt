extends GutTest

const ProgramValidationErrorScript = preload("res://src/programming/domain/program_validation_error.gd")
const ValidationFeedbackMapperScript = preload("res://src/brain_editor/validation_feedback_mapper.gd")

func test_maps_known_validation_errors_to_messages() -> void:
	var mapper = ValidationFeedbackMapperScript.new()
	var error = ProgramValidationErrorScript.new(
		ProgramValidationErrorScript.Code.RAM_LIMIT_EXCEEDED
	)

	assert_eq(mapper.message_for_error(error), "O programa conectado ultrapassa 5 RAM.")

func test_maps_multiple_errors_to_non_empty_messages() -> void:
	var mapper = ValidationFeedbackMapperScript.new()
	var errors := [
		ProgramValidationErrorScript.new(ProgramValidationErrorScript.Code.MISSING_START),
		ProgramValidationErrorScript.new(ProgramValidationErrorScript.Code.ARBITRARY_CYCLE),
	]

	var messages := mapper.messages_for_errors(errors)

	assert_eq(messages.size(), 2)
	assert_false(messages[0].is_empty())
	assert_false(messages[1].is_empty())

func test_null_error_returns_empty_message() -> void:
	var mapper = ValidationFeedbackMapperScript.new()

	assert_eq(mapper.message_for_error(null), "")
