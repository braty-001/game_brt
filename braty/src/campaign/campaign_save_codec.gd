class_name CampaignSaveCodec
extends RefCounted

const SessionScript = preload("res://src/campaign/campaign_session.gd")
const AssemblyScript = preload("res://src/buneko/domain/buneko_assembly.gd")
const BasePartsScript = preload("res://src/buneko/domain/base_buneko_parts.gd")
const GraphScript = preload("res://src/brain_editor/editor_graph_state.gd")
const BlockScript = preload("res://src/brain_editor/editor_block_state.gd")
const ConnectionScript = preload("res://src/brain_editor/editor_connection_state.gd")
const ConditionScript = preload("res://src/programming/domain/program_condition.gd")
const Catalog = preload("res://src/campaign/campaign_mission_catalog.gd")

const VERSION := 1
const MAX_BLOCKS := 256
const MAX_CONNECTIONS := 512
const MAX_COORDINATE := 100000.0

static func encode(session) -> Dictionary:
	var parts: Array = []
	if session.assembly != null:
		for slot in session.assembly.parts_by_slot:
			var part = session.assembly.parts_by_slot[slot]
			parts.append({"slot": slot, "id": part.id})
	parts.sort_custom(func(a, b): return a["slot"] < b["slot"])
	var graph_data = null
	if session.graph_state != null:
		var blocks: Array = []
		var block_ids: Array = session.graph_state.blocks.keys()
		block_ids.sort()
		for block_id in block_ids:
			var block = session.graph_state.blocks[block_id]
			var condition_data = null
			if block.condition != null:
				condition_data = {"modality": block.condition.modality, "query": block.condition.query}
			blocks.append({
				"id": block.id, "kind": block.kind,
				"position": [block.position.x, block.position.y],
				"condition": condition_data, "parameters": block.parameters.duplicate(true),
			})
		var connections: Array = []
		for connection in session.graph_state.connections:
			connections.append({
				"from": connection.from_block_id, "port": connection.from_port,
				"to": connection.to_block_id, "input": connection.to_port,
			})
		graph_data = {"start": session.graph_state.start_block_id, "blocks": blocks, "connections": connections}
	return {
		"version": VERSION,
		"tutorial_completed": session.tutorial_completed,
		"mission_id": Catalog.LABORATORY_ID if session.tutorial_completed else "",
		"campaign_ram": Catalog.INITIAL_RAM if session.tutorial_completed else 0,
		"parts": parts,
		"graph": graph_data,
		"preparation_confirmed": session.preparation_confirmed,
		"baton_checkpoint_active": session.baton_checkpoint_active,
		"baton_checkpoint_intro_seen": session.baton_checkpoint_intro_seen,
		"money": session.money,
		"laboratory_first_completed": session.laboratory_first_completed,
	}

static func decode(data):
	if typeof(data) != TYPE_DICTIONARY or not _is_integer(data.get("version")) or int(data["version"]) != VERSION:
		return null
	for field in ["tutorial_completed", "preparation_confirmed", "baton_checkpoint_active", "baton_checkpoint_intro_seen", "laboratory_first_completed"]:
		if typeof(data.get(field)) != TYPE_BOOL:
			return null
	if typeof(data.get("mission_id")) != TYPE_STRING or not _is_integer(data.get("campaign_ram")):
		return null
	if data["mission_id"] != (Catalog.LABORATORY_ID if data["tutorial_completed"] else ""):
		return null
	if int(data["campaign_ram"]) != (Catalog.INITIAL_RAM if data["tutorial_completed"] else 0):
		return null
	if not _is_integer(data.get("money")) or int(data["money"]) < 0 or int(data["money"]) > 1000000000:
		return null
	if not data.has("parts") or typeof(data["parts"]) != TYPE_ARRAY:
		return null
	var assembly = _decode_assembly(data["parts"])
	if assembly == null:
		return null
	if not data.has("graph"):
		return null
	var graph = null
	if data["graph"] != null:
		graph = _decode_graph(data["graph"])
		if graph == null:
			return null
	if data["tutorial_completed"] and (not assembly.is_complete() or graph == null):
		return null
	if not data["tutorial_completed"] and (not data["parts"].is_empty() or graph != null):
		return null
	if data["preparation_confirmed"] and not data["tutorial_completed"]:
		return null
	if data["baton_checkpoint_active"] and not data["tutorial_completed"]:
		return null
	if data["baton_checkpoint_intro_seen"] and not data["baton_checkpoint_active"]:
		return null
	if data["laboratory_first_completed"] and not data["tutorial_completed"]:
		return null
	var session = SessionScript.new()
	session.tutorial_completed = data["tutorial_completed"]
	session.assembly = assembly if session.tutorial_completed else null
	session.graph_state = graph
	session.preparation_confirmed = data["preparation_confirmed"]
	session.baton_checkpoint_active = data["baton_checkpoint_active"]
	session.baton_checkpoint_intro_seen = data["baton_checkpoint_intro_seen"]
	session.money = int(data["money"])
	session.laboratory_first_completed = data["laboratory_first_completed"]
	return session

static func _decode_assembly(parts):
	if parts.size() > 3:
		return null
	var assembly = AssemblyScript.new()
	var known_parts := {
		BasePartsScript.HEAD_ID: BasePartsScript.head(),
		BasePartsScript.BODY_ID: BasePartsScript.body(),
		BasePartsScript.LOCOMOTION_ID: BasePartsScript.locomotion(),
	}
	for entry in parts:
		if typeof(entry) != TYPE_DICTIONARY or typeof(entry.get("id")) != TYPE_STRING or not _is_integer(entry.get("slot")):
			return null
		var part = known_parts.get(entry["id"])
		if part == null or part.slot != int(entry["slot"]) or assembly.part_for_slot(part.slot) != null:
			return null
		assembly.install_part(part)
	return assembly

static func _decode_graph(data):
	if typeof(data) != TYPE_DICTIONARY or typeof(data.get("start")) != TYPE_STRING:
		return null
	if typeof(data.get("blocks")) != TYPE_ARRAY or typeof(data.get("connections")) != TYPE_ARRAY:
		return null
	if data["blocks"].size() > MAX_BLOCKS or data["connections"].size() > MAX_CONNECTIONS:
		return null
	var graph = GraphScript.new()
	for entry in data["blocks"]:
		if typeof(entry) != TYPE_DICTIONARY or typeof(entry.get("id")) != TYPE_STRING or not _is_integer(entry.get("kind")):
			return null
		var block_id: String = entry["id"]
		var kind := int(entry["kind"])
		if block_id.is_empty() or block_id.length() > 128 or not ProgramBlockKind.is_valid(kind):
			return null
		var position = entry.get("position")
		if typeof(position) != TYPE_ARRAY or position.size() != 2 or not _is_coordinate(position[0]) or not _is_coordinate(position[1]):
			return null
		if not entry.has("condition") or not entry.has("parameters") or typeof(entry["parameters"]) != TYPE_DICTIONARY:
			return null
		var condition = null
		if entry["condition"] != null:
			var condition_data = entry["condition"]
			if typeof(condition_data) != TYPE_DICTIONARY or not _is_integer(condition_data.get("modality")) or not _is_integer(condition_data.get("query")):
				return null
			condition = ConditionScript.new(int(condition_data["modality"]), int(condition_data["query"]))
			if not condition.is_valid():
				return null
		var parameters: Dictionary = entry["parameters"].duplicate(true)
		if not _valid_block_fields(kind, condition, parameters):
			return null
		if kind == ProgramBlockKind.Value.WALK and parameters.has(MovementPace.PARAMETER_KEY):
			parameters[MovementPace.PARAMETER_KEY] = int(parameters[MovementPace.PARAMETER_KEY])
		if not graph.add_block(BlockScript.new(block_id, kind, Vector2(float(position[0]), float(position[1])), condition, parameters)):
			return null
	if not data["start"].is_empty() and not graph.set_start_block(data["start"]):
		return null
	for entry in data["connections"]:
		if typeof(entry) != TYPE_DICTIONARY:
			return null
		for field in ["from", "port", "to", "input"]:
			if typeof(entry.get(field)) != TYPE_STRING:
				return null
		if not graph.blocks.has(entry["from"]) or not graph.blocks.has(entry["to"]):
			return null
		if not ProgramBlockKind.output_ports(graph.blocks[entry["from"]].kind).has(entry["port"]) or entry["input"] != "input":
			return null
		if not graph.add_connection(ConnectionScript.new(entry["from"], entry["port"], entry["to"], entry["input"])):
			return null
	return graph

static func _valid_block_fields(kind: int, condition, parameters: Dictionary) -> bool:
	if ProgramBlockKind.requires_condition(kind):
		return parameters.is_empty()
	if condition != null:
		return false
	if kind == ProgramBlockKind.Value.WALK:
		if parameters.is_empty():
			return true
		return parameters.size() == 1 and parameters.has(MovementPace.PARAMETER_KEY) and _is_integer(parameters[MovementPace.PARAMETER_KEY]) and MovementPace.is_valid(int(parameters[MovementPace.PARAMETER_KEY]))
	return parameters.is_empty()

static func _is_integer(value) -> bool:
	return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and absf(float(value)) <= 1000000000.0 and float(value) == floorf(float(value))

static func _is_coordinate(value) -> bool:
	return (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT) and absf(float(value)) <= MAX_COORDINATE
