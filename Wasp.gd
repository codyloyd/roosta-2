extends "res://Enemy.gd"

var has_attacked_this_turn = false

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	hp = 1
	type="wasp"
	move_speed = .2


func take_turn():
	has_attacked_this_turn = false
	if stunned:
		stunned = false
		return
	if dead:
		return

	.take_turn()
	if not has_attacked_this_turn:
		$TurnTimer.start()
		yield($TurnTimer, "timeout")
		.take_turn()


func attack(enemy):
	has_attacked_this_turn = true
	.attack(enemy)
