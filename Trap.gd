extends Node2D

class_name Trap


func _ready():
	add_to_group("traps")
	pass


func act_on(entity):
	if entity.is_player:
		entity.take_damage(1)
	else:
		entity.take_damage(2)

	queue_free()
