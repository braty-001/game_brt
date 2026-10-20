class_name CampaignSaveStore
extends RefCounted

const Codec = preload("res://src/campaign/campaign_save_codec.gd")
const DEFAULT_PATH := "user://campaign_progress.json"

var save_path: String
var blocked := false

func _init(path: String = DEFAULT_PATH) -> void:
	save_path = path

func load_progress() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		blocked = false
		return {"status": "missing", "session": null}
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		blocked = true
		return {"status": "invalid", "session": null}
	var contents := file.get_as_text()
	file.close()
	var parser := JSON.new()
	if parser.parse(contents) != OK:
		blocked = true
		return {"status": "invalid", "session": null}
	var session = Codec.decode(parser.data)
	if session == null:
		blocked = true
		return {"status": "invalid", "session": null}
	blocked = false
	return {"status": "ok", "session": session}

func save_progress(session) -> bool:
	if blocked or session == null:
		return false
	var data: Dictionary = Codec.encode(session)
	if Codec.decode(data) == null:
		return false
	var directory := ProjectSettings.globalize_path(save_path.get_base_dir())
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		return false
	var temporary_path := save_path + ".tmp"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_path))
		return false
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary_path), ProjectSettings.globalize_path(save_path))
	if rename_error != OK:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_path))
		return false
	return true

func replace_with_new_game(session) -> bool:
	var was_blocked := blocked
	blocked = false
	if save_progress(session):
		return true
	blocked = was_blocked
	return false
