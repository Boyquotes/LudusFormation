extends Area2D
class_name Trap

@export var damage : int = 1
@export var saw_activated : bool = false:
	set(b):
		saw_activated = b
		if b:
			$SawAnimations.play("On")
		else:
			$SawAnimations.play("Idle")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered_saw_trap)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass

func _on_body_entered_saw_trap(body: Node2D) -> void:
	body.call_deferred("take_damage", damage)
