class_name BrainEditorSnapshot
extends RefCounted

var graph_state
var program
var ram: String
var status: String
var is_valid: bool

func _init(
	snapshot_graph_state,
	snapshot_program,
	snapshot_ram: String,
	snapshot_status: String,
	snapshot_is_valid: bool
) -> void:
	graph_state = snapshot_graph_state
	program = snapshot_program
	ram = snapshot_ram
	status = snapshot_status
	is_valid = snapshot_is_valid
