extends "res://Enemy.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	type="star"
	move_speed = .6


func take_turn():
	if stunned:
		stunned = false
		return
	if dead:
		return

	.take_turn()
	stunned = true


func attack(enemy):
	.attack(enemy)
