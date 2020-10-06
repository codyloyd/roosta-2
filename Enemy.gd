class_name Enemy
extends 'entity.gd'

var move_speed = .4
var attack_speed = .6
var stunned = false
var stun_timer = 0

onready var tween = get_node("Tween")
onready var player = get_parent().get_parent().player


# Called when the node enters the scene tree for the first time.
func _ready():
	type = "duck"
	add_to_group("enemies")
	add_to_group("entities")
	hp = 2
	$AnimationPlayer.play("setup")


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
	var path = map.get_pathv(position, player.position)
	var new_position
	if path:
		var tile = path[0]
		if path.size() > 1:
			tile = path[1]
			var direction = (tile - map.world_to_map(position)).normalized()
			new_position = map.update_entity_position(self, direction)
	else:
		new_position = get_simple_direction(player)
		
	if new_position is Vector2:
		move(new_position)
		var trap = map.get_trap(new_position)
		if trap:
			trap.act_on(self)

	elif new_position.is_player:
		attack(new_position)


func get_simple_direction(player):
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
	
	return new_position

func take_damage(damage = 1):
	.take_damage(damage)
	stunned = true
	if not dead:
		$AnimationPlayer.play("hurt")
		$ShakeTimer.start()
		$hit_sound.play()


func move(new_position):
	var move_direction = (new_position - position).normalized()
	var old_sprite_position = Vector2(16, 16) - (move_direction * 32)
	tween.interpolate_property($Sprite, "position",
			old_sprite_position, Vector2(16,16), move_speed, 
			Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Sprite.position = position - new_position + Vector2(16,16)
	position = new_position
	tween.start()


func attack(enemy):
	var enemy_vector = enemy.position
	var move_direction = (enemy_vector - position).normalized()
	var goal_vector = (move_direction * 24) + Vector2(16, 16)
	tween.interpolate_property($Sprite, "position",
			goal_vector, Vector2(16, 16), attack_speed,
			Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	
	enemy.take_damage()


func die():
	print('dead')
	
	$AnimationPlayer.play("die")
	$pop.play()
	$Particles.restart()
	$DeathTimer.start()
	
	yield($DeathTimer, "timeout")
	.die()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !$ShakeTimer.is_stopped():
		$Sprite.offset.x = rand_range(-50,50) * $ShakeTimer.time_left
		$Sprite.offset.y = rand_range(-50,50) * $ShakeTimer.time_left












