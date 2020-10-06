extends "res://Enemy.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	hp = 2
	type="crab"


func take_turn():
	if stun_timer == 2:
		stunned = false
		stun_timer = 0

	if stunned:
		stun_timer += 1
		return
		
	if dead:
		return
		
	player = get_parent().get_parent().player
	var direction = position.direction_to(player.position).snapped(Vector2(1,1))
	var new_position = null
	if abs(direction.x) > 0 and abs(direction.y) > 0:
		var pos_x = map.update_entity_position(self, Vector2(direction.x, 0))
		var pos_y = map.update_entity_position(self, Vector2(0, direction.y))
		if pos_x is Vector2:
			new_position = pos_x
		else: 
			new_position = pos_y
	else:
		new_position = map.update_entity_position(self, direction)

	if new_position is Vector2:
		move(new_position)
		var trap = map.get_trap(new_position)
		if trap:
			trap.act_on(self)
	elif new_position.is_player:
		attack(new_position)


func can_walk_on(tile):
	return tile
	
func take_damage(damage = 1):
	.take_damage(damage)
	if not dead:
		$AnimationPlayer.play("hurt")
