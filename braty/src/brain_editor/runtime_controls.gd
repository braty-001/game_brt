class_name BrainEditorRuntimeControls
extends RefCounted

const ProgramGraphBuilderScript = preload("res://src/brain_editor/program_graph_builder.gd")

var runtime
var graph_builder

func _init(editor_runtime = null, editor_graph_builder = null) -> void:
	runtime = editor_runtime
	if editor_graph_builder == null:
		graph_builder = ProgramGraphBuilderScript.new()
	else:
		graph_builder = editor_graph_builder

func prepare_from_graph(graph_state) -> bool:
	if runtime == null:
		return false

	return runtime.prepare(graph_builder.build(graph_state))

func start() -> bool:
	return runtime != null and runtime.start()

func pause() -> bool:
	return runtime != null and runtime.pause()

func resume() -> bool:
	return runtime != null and runtime.resume()

func stop() -> bool:
	return runtime != null and runtime.stop()

func restart() -> bool:
	return runtime != null and runtime.restart()
