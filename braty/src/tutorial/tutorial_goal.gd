class_name TutorialGoal
extends Area2D

signal reached

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D) -> void:
	reached.emit()
