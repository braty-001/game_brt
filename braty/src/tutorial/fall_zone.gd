class_name TutorialFallZone
extends Area2D

signal fallen

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D) -> void:
	fallen.emit()
