extends Node2D

# has a map, a player and all the entites.
# is in charge of setting everything up and passing info to the player and map
# should how many enemies/what kind of enemies we're creating

class_name Level

signal unlock_player
signal level_ready
signal update_level

onready var map = get_node("Map")
var Player = load("res://Player.tscn")
var Enemy = load("res://Enemy.tscn")
var Crab = load("res://Crab.tscn")
var Wasp = load("res://Wasp.tscn")
var Star = load("res://Star.tscn")

var enemyArray = [Enemy, Crab, Wasp, Star]
var enemies = []
var player
var level = 1
var turns = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	new_level()

func spawn_enemy():
	enemyArray.shuffle()
	var enemy = enemyArray[0].instance()
	var enemy_pos = map.random_empty_world_coords()
	enemy.init(enemy_pos, map)
	enemy.stunned = true
	enemies.append(weakref(enemy))
	map.add_child(enemy)

func new_level():
	map.setup()

	for e in get_tree().get_nodes_in_group('enemies'):
		e.queue_free()

	for _i in range(level + 1):
		spawn_enemy()

	if not player:
		player = Player.instance()
		player.connect("game_tick", self, "game_tick")
		player.connect("player_exit", self, "on_player_exit")
		connect("unlock_player", player, "unlock_player")

	var player_pos = map.random_empty_world_coords()
	player.init(player_pos, map)
	if player.spells:
		player.spells.get_new_spell()
		player.update_spell_ui()
	map.add_child(player)
	emit_signal("level_ready")
	emit_signal("update_level", level)

func on_player_exit():
	level += 1
	player.hp = min(player.hp + 1, player.max_hp);
	player.update_hp()
	new_level()

func game_tick():
	player.update_spell_ui()
	for s in player.spells.spells:
		s.cooldown = max(s.cooldown - 1, 0)
	$TurnTimer.start()
	yield($TurnTimer, "timeout")

	var new_enemies_array = []
	for e in enemies:
		if e.get_ref():
			new_enemies_array.append(e)

	enemies = new_enemies_array
	for e in enemies:
		e.get_ref().take_turn()

	turns += 1
	if turns % 10 == 0:
		spawn_enemy()
	
	$TurnTimer.start()
	yield($TurnTimer, "timeout")
	
	emit_signal("unlock_player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
