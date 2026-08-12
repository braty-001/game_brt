extends GutTest

const BlockKind = preload("res://src/programming/domain/block_kind.gd")
const EditorBlockStateScript = preload("res://src/brain_editor/editor_block_state.gd")
const EditorGraphStateScript = preload("res://src/brain_editor/editor_graph_state.gd")
const RuntimeControlsScript = preload("res://src/brain_editor/runtime_controls.gd")

class FakeRuntime:
	var prepared_program
	var calls: Array[String] = []

	func prepare(program) -> bool:
		prepared_program = program
		calls.append("prepare")
		return not program.start_block_id.is_empty()

	func start() -> bool:
		calls.append("start")
		return true

	func pause() -> bool:
		calls.append("pause")
		return true

	func resume() -> bool:
		calls.append("resume")
		return true

	func stop() -> bool:
		calls.append("stop")
		return true

	func restart() -> bool:
		calls.append("restart")
		return true

func test_prepare_from_graph_builds_program_for_runtime() -> void:
	var graph = EditorGraphStateScript.new()
	graph.start_block_id = "walk"
	graph.add_block(EditorBlockStateScript.new("walk", BlockKind.Value.WALK))
	var runtime := FakeRuntime.new()
	var controls = RuntimeControlsScript.new(runtime)

	assert_true(controls.prepare_from_graph(graph))

	assert_eq(runtime.calls, ["prepare"])
	assert_eq(runtime.prepared_program.start_block_id, "walk")

func test_runtime_control_methods_delegate_to_runtime() -> void:
	var runtime := FakeRuntime.new()
	var controls = RuntimeControlsScript.new(runtime)

	assert_true(controls.start())
	assert_true(controls.pause())
	assert_true(controls.resume())
	assert_true(controls.stop())
	assert_true(controls.restart())

	assert_eq(runtime.calls, ["start", "pause", "resume", "stop", "restart"])
