extends Node2D

var jump_force = Vector2(0, -10)

func jump() -> void:
	$body.add_central_force(jump_force)
