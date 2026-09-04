class_name TutorialBrainExampleProvider
extends "res://src/brain_editor/editor_example_provider.gd"

const ReferenceProgramScript = preload("res://src/tutorial/tutorial_reference_program.gd")

func entries() -> Array[Dictionary]:
	return [
		{
			"id": ReferenceProgramScript.Example.IF_GAP,
			"label": "Exemplo com IF + WHILE",
		},
		{
			"id": ReferenceProgramScript.Example.WHILE_PATH_CLEAR,
			"label": "Exemplo com WHILE",
		},
	]

func default_example_id() -> int:
	return ReferenceProgramScript.Example.WHILE_PATH_CLEAR

func build_program(example_id: int):
	return ReferenceProgramScript.build_example(example_id)
