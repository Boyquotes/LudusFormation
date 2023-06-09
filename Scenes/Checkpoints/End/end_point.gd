extends Area2D

@export_file("*.tscn") var next_level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().change_scene_to_file(next_level)
