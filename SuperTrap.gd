extends Node2D

class_name SuperTrap


func _ready():
	add_to_group("traps")
	pass


func act_on(entity):
	if entity.is_player:
		entity.take_damage(1)
	else:
		for node in get_tree().get_nodes_in_group("entities"):
			print(node.type)
			if node.type == entity.type:
				node.take_damage(2)

	queue_free()
