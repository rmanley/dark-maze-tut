extends Node


func _ready():
	randomize()


func play():
	var i = randi() % 3
	get_children()[i].play()
