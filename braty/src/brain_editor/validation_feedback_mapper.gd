class_name ValidationFeedbackMapper
extends RefCounted

func message_for_error(error: ProgramValidationError) -> String:
	if error == null:
		return ""

	match error.code:
		ProgramValidationError.Code.MISSING_START:
			return "Conecte um bloco ao inicio do programa."
		ProgramValidationError.Code.UNKNOWN_START:
			return "O bloco inicial nao existe mais."
		ProgramValidationError.Code.INVALID_BLOCK:
			return "Revise os parametros do bloco."
		ProgramValidationError.Code.UNKNOWN_CONNECTION_BLOCK:
			return "Remova a conexao ligada a um bloco inexistente."
		ProgramValidationError.Code.INVALID_OUTPUT_PORT:
			return "Esta saida nao existe para este tipo de bloco."
		ProgramValidationError.Code.INVALID_INPUT_PORT:
			return "Esta entrada nao aceita essa conexao."
		ProgramValidationError.Code.DUPLICATE_OUTPUT:
			return "Esta saida ja possui uma conexao."
		ProgramValidationError.Code.DUPLICATE_INPUT:
			return "Este bloco ja possui uma entrada conectada."
		ProgramValidationError.Code.ARBITRARY_CYCLE:
			return "Use WHILE para repetir; ciclos livres nao sao permitidos."
		ProgramValidationError.Code.RAM_LIMIT_EXCEEDED:
			return "O programa conectado ultrapassa 5 RAM."
		_:
			return "Revise o programa antes de iniciar."

func messages_for_errors(errors: Array) -> PackedStringArray:
	var messages := PackedStringArray()
	for error in errors:
		var message := message_for_error(error)
		if not message.is_empty():
			messages.append(message)

	return messages
