extends Node2D

class_name Potato

var taken = false

signal eaten_potato

func _on_Area2D_body_entered(body) -> void:
	if not taken and body is Player:
		taken = true
		$AnimationPlayer.play("Disappear")
		$AudioStreamPlayer.play()
		emit_signal("eaten_potato")

func die() -> void:
	queue_free()

func get_size() -> Vector2:
	return $Area2D/CollisionShape2D.shape.extents * 2 * scale
