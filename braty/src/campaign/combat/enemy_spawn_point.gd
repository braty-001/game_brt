class_name EnemySpawnPoint
extends Marker2D

@export var enemy_scene: PackedScene
@export_range(0.0, 2000.0, 1.0) var patrol_left_distance := 0.0
@export_range(0.0, 2000.0, 1.0) var patrol_right_distance := 0.0
@export_enum("Left:-1", "Right:1") var initial_direction := 1

func spawn_enemy(parent: Node, target, sight_check: Callable):
	if enemy_scene == null or parent == null:
		return null
	var enemy = enemy_scene.instantiate()
	if not enemy.has_method("configure"):
		enemy.queue_free()
		return null
	parent.add_child(enemy)
	enemy.global_position = global_position
	enemy.configure(
		target,
		sight_check,
		global_position.x - patrol_left_distance,
		global_position.x + patrol_right_distance,
		initial_direction
	)
	return enemy
