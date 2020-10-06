class_name Player
extends 'entity.gd'

signal game_tick
signal update_hp
signal projectile_spawn
signal player_exit

var move_speed = .3
var attack_speed = .6
var max_hp = 3

onready var spells = $Spells
onready var Game = get_tree().get_root().get_node("Game")

onready var tween = get_node("Tween")

var direction_function = null

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("entities")
	hp = 3
	is_player = true
	type = "ROOSTA"
	update_spell_ui()


func _physics_process(_delta):
	if !$ShakeTimer.is_stopped():
		$Sprite.offset.x = rand_range(-30,30) * $ShakeTimer.time_left
		$Sprite.offset.y = rand_range(-30,30) * $ShakeTimer.time_left
		$Sprite.modulate = Color(10,1,1,10)
	else:
		$Sprite.modulate = Color(1,1,1,1)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_focus_next"):
		print(Game)

	
	if Input.is_action_just_pressed("ui_select"):
		get_tree().reload_current_scene()

	if Game.lock_player:
		return

	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("game_tick")

	if direction_function:
		if Input.is_action_just_pressed("ui_cancel"):
			direction_function = null
		if Input.is_action_just_pressed("move_right"):
			direction_function.call_func(Vector2.RIGHT)
			direction_function = null
			return
		elif Input.is_action_just_pressed("move_left"):
			direction_function.call_func(Vector2.LEFT)
			direction_function = null
			return
		elif Input.is_action_just_pressed("move_down"):
			direction_function.call_func(Vector2.DOWN)
			direction_function = null
			return
		elif Input.is_action_just_pressed("move_up"):
			direction_function.call_func(Vector2.UP)
			direction_function = null
			return

	var input_direction = get_input_direction()
	if input_direction:
		var new_position = map.update_entity_position(self, input_direction)
		
		if new_position is Vector2:
			move(new_position)

		elif new_position is Enemy:
			attack(new_position)
		else:
			bump()
	


func get_input_direction():
	return Vector2(
		int(Input.is_action_just_pressed("move_right")) - int(Input.is_action_just_pressed("move_left")),
		int(Input.is_action_just_pressed("move_down")) - int(Input.is_action_just_pressed("move_up"))
	)


func move(new_position):
	set_process(false)
	var move_direction = (new_position - position).normalized()
	var old_sprite_position = Vector2(16, 16) - (move_direction * 32)
	tween.interpolate_property($Sprite, "position",
			old_sprite_position, Vector2(16, 16), move_speed, 
			Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Sprite.position = position - new_position + Vector2(16,16)
	position = new_position

	var trap = map.get_trap(new_position)
	if trap:
		trap.act_on(self)
	tween.start()

	if map.is_exitv(map.world_to_map(position)):
		emit_signal("player_exit")
	
	emit_signal("game_tick")


func attack(enemy: Enemy):
	set_process(false)
	var enemy_vector = enemy.position
	var move_direction = (enemy_vector - position).normalized()
	var goal_vector = (move_direction * 24) + Vector2(16, 16)
	tween.interpolate_property($Sprite, "position",
			goal_vector, Vector2(16, 16), attack_speed,
			Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	enemy.take_damage()
	emit_signal("game_tick")


func take_damage(damage = 1):
	.take_damage(damage)
	update_hp()
	if not dead:
		$ShakeTimer.start()
		$hit_sound.play()



func bump():
	$AnimationPlayer.play("bump")
	

func die():
	print("YOU DED")


func unlock_player():
	set_process(true)


func _on_swipe(input_direction):
	if input_direction:
		if direction_function:
			direction_function.call_func(input_direction)
			direction_function = null
			return

		var new_position = map.update_entity_position(self, input_direction)
		
		if new_position is Vector2:
			move(new_position)

		elif new_position is Enemy:
			attack(new_position)
		else:
			bump()
	

func update_spell_ui():
	var buttons = get_tree().get_root().get_node("Game/UI/MarginContainer/VBoxContainer/ButtonContainer").get_children()
	var i = 0
	for s in spells.spells:
		buttons[i].text = s.name
		if s.cooldown <= 0:
			buttons[i].disabled = false
		else:
			buttons[i].disabled = true

		i += 1


# handle swipe input!!

signal swipe_canceled(start_position)
export(float, 1.0, 1.5) var max_diagonal_slope: = 1.3
onready var timer: Timer = $SwipeTimeout
var swipe_start_position: = Vector2()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventScreenTouch:
		return
	if event.pressed:
		_start_detection(event.position)
	elif not timer.is_stopped():
		_end_detection(event.position)


func _start_detection(position: Vector2) -> void:
	swipe_start_position = position
	timer.start()


func _end_detection(position: Vector2) -> void:
	timer.stop()
	var direction: Vector2 = (position - swipe_start_position).normalized()
	# Swipe angle is too steep
	if abs(direction.x) + abs(direction.y) >= max_diagonal_slope:
		return

	var swipe_direction = Vector2()
	if abs(direction.x) > abs(direction.y):
		swipe_direction = Vector2(sign(direction.x), 0.0)
	else:
		swipe_direction = Vector2(0.0, sign(direction.y))

	_on_swipe(swipe_direction)


func update_hp():
	emit_signal("update_hp", hp)
