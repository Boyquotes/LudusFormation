extends Area2D
class_name CheckpointStart

var taken : bool = false:
	set(b):
		if taken == b:
			return
		
		taken = b
		if b:
			$StartSprite.play("Moving")
			$StartSprite.self_modulate = Color.GREEN
			$CheckpointReached.emitting = true
			
			for checkpoint_start in get_tree().get_nodes_in_group("checkpoint_start"):
				if checkpoint_start == self:
					continue
				
				(checkpoint_start as CheckpointStart).taken = false
		else:
			$StartSprite.play("Idle")
			$StartSprite.self_modulate = Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body : Node2D) -> void:
	if not taken:
		if body is Player:
			taken = true
			body.start_point = global_position
