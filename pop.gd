extends Node

func play():
	var children = get_children()
	var pop = children[randi() % children.size()]
	pop.play()
