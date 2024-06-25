extends Node

@onready var animation_player = $AnimationPlayer
var Main = preload("res://scenes/main.tscn")

func _ready():
	animation_player.play("intro")
	

func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_packed(Main)
