class_name ProgramConnection
extends RefCounted

var from_block_id: String
var from_port: String
var to_block_id: String
var to_port: String

func _init(
	connection_from_block_id: String,
	connection_from_port: String,
	connection_to_block_id: String,
	connection_to_port: String = "input"
) -> void:
	from_block_id = connection_from_block_id
	from_port = connection_from_port
	to_block_id = connection_to_block_id
	to_port = connection_to_port
