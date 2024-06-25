extends Area2D

func _process(delta):
	position.x -= get_parent().speed / 2
