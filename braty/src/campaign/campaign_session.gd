class_name CampaignSession
extends RefCounted

const Catalog = preload("res://src/campaign/campaign_mission_catalog.gd")

var tutorial_completed := false
var assembly
var graph_state
var preparation_confirmed := false
var baton_checkpoint_active := false
var baton_checkpoint_intro_seen := false

func complete_tutorial(completed_assembly, completed_graph) -> void:
	if tutorial_completed:
		return
	tutorial_completed = true
	assembly = completed_assembly
	graph_state = completed_graph

func can_prepare_mission(mission_id: String) -> bool:
	return tutorial_completed and mission_id == Catalog.LABORATORY_ID

func keep_draft(snapshot) -> void:
	graph_state = snapshot.graph_state
	preparation_confirmed = false

func confirm_preparation(snapshot) -> bool:
	if not can_prepare_mission(Catalog.LABORATORY_ID):
		return false
	keep_draft(snapshot)
	preparation_confirmed = program_can_run(snapshot.program)
	return preparation_confirmed

func program_can_run(program) -> bool:
	if not ProgramValidator.validate(program, Catalog.INITIAL_RAM).is_empty():
		return false
	if baton_checkpoint_active:
		return true
	for block_id in program.reachable_block_ids():
		if program.blocks[block_id].kind == ProgramBlockKind.Value.ATTACK:
			return false
	return true

func activate_baton_checkpoint() -> bool:
	var first_activation := not baton_checkpoint_active
	baton_checkpoint_active = true
	baton_checkpoint_intro_seen = true
	preparation_confirmed = false
	return first_activation
