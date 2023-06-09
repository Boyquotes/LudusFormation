extends GPUParticles2D

#var deletion : bool = false
#
#func _process(delta: float) -> void:
#	if emitting == false and not deletion:
#		deletion = true
#		await get_tree().create_timer(2.0).timeout
#		queue_free()
