extends Node2D

onready var player = get_parent()
onready var map = player.map
var spells = []
var max_spells = 7

var Trap = load("res://Trap.tscn")
var SuperTrap = load("res://SuperTrap.tscn")

var registeredSpells = [
	{
		"spell": funcref(self, "jump"), #0
		"name": "jump",
		"cooldown": 0,
		"uses": 0,
		"desc": "jump to a random position on the map",
	},
	{
		"spell": funcref(self, "hurricane"), #1
		"name": "hurricane",
		"cooldown": 0,
		"uses": 0,
		"desc": "shuffle those enemies around the board"
	},
	{
		"spell": funcref(self, "heal"), #2
		"name": "heal",
		"cooldown": 0,
		"uses": 0,
		"desc": "get some life back!"
	},
	{
		"spell": funcref(self, "col"), #3
		"name": "column",
		"cooldown": 0,
		"uses": 0,
		"desc": "damage all in column"
	},
	{
		"spell": funcref(self, "row"), #4
		"name": "row",
		"cooldown": 0,
		"uses": 0,
		"desc": "damage all in row"
	},
	{
		"spell": funcref(self, "push"), #5
		"name": "push",
		"cooldown": 0,
		"uses": 0,
		"desc": "push all enemies away from you"
	},
	{
		"spell": funcref(self, "pull"), #6
		"name": "pull",
		"cooldown": 0,
		"uses": 0,
		"desc": "pull all enemies toward you"
	},
	{
		"spell": funcref(self, "stun"), #7
		"name": "stun",
		"cooldown": 0,
		"uses": 0,
		"desc": "stuns all enemies for 1 turn"
	},
	{
		"spell": funcref(self, "dispatch_beachball_function"), #8
		"name": "beachball",
		"cooldown": 0,
		"uses": 0,
		"desc": "throw a beachball!"
	},
	{
		"spell": funcref(self, "dispatch_dash"), #9
		"name": "dash",
		"cooldown": 0,
		"uses": 0,
		"desc": "dash in some direction, damage enemies that you hit"
	},
	{
		"spell": funcref(self, "dispatch_trap"), #10
		"name": "trap",
		"cooldown": 0,
		"uses": 0,
		"desc": "Set a trap on an empty space, will damage any enemy that steps on it."
	},
	{
		"spell": funcref(self, "dispatch_super_trap"), #11
		"name": "super trap",
		"cooldown": 0,
		"uses": 0,
		"desc": "set a super trap! will damage all of the type of enemy that steps on it."
	},
	{
		"spell": funcref(self, "water_attack"), #12
		"name": "water attack",
		"cooldown": 0,
		"uses": 0,
		"desc": "will damage any enemy standing in the water."
	},
	{
		"spell": funcref(self, "bug_spray"), #13
		"name": "bug spray",
		"cooldown": 0,
		"uses": 0,
		"desc": "kill all the wasps!"
	},
	{
		"spell": funcref(self, "wait"), #14
		"name": "wait",
		"cooldown": 0,
		"uses": 0,
		"desc": "stay in place for one turn"
	},
]

func _ready():
	get_new_spell()
	get_new_spell()


func get_new_spell():
	if spells.size() < max_spells:
		var new_spell = Utils.random_from_array(registeredSpells).duplicate()
		for spell in spells:
			if new_spell.name == spell.name:
				get_new_spell()
				return

		spells.append(new_spell)


func jump():
	var new_coords = map.random_empty_coords()
	player.move(map.map_to_world(new_coords))



func hurricane():
	var enemies = map.get_parent().enemies
	for e in enemies:
		e.get_ref().move(map.map_to_world(map.random_empty_coords()))


func heal():
	player.hp = min(player.hp + 1, player.max_hp);
	player.update_hp()


func col():
	var entities = map.get_column_entities(map.world_to_map(player.position).x)
	for e in entities:
		if not e is Player:
			e.take_damage()


func row():
	var entities = map.get_row_entities(map.world_to_map(player.position).y)
	for e in entities:
		if not e is Player:
			e.take_damage()


func push():
	var entities = get_tree().get_nodes_in_group("enemies")
	for e in entities:
		var direction_vector = e.position.direction_to(player.position).snapped(Vector2(1,1))
		e.has_been_moved = true
		e.move(map.get_new_world_position(e, direction_vector * -1))


func pull():
	var entities = get_tree().get_nodes_in_group("enemies")
	for e in entities:
		var direction_vector = e.position.direction_to(player.position).snapped(Vector2(1,1))
		e.has_been_moved = true
		var new_pos = map.get_new_world_position(e, direction_vector)
		if new_pos != player.position:
			e.move(map.get_new_world_position(e, direction_vector))


func stun():
	var entities = get_tree().get_nodes_in_group("enemies")
	for e in entities:
		if not e is Player:
			e.stunned = true



func dispatch_beachball_function():
	player.direction_function = funcref(self, 'beachball')


# TODO: allow throwing off screen?
func beachball(direction: Vector2):
	var player_map_pos = map.world_to_map(player.position)
	if direction.x == 0:
	# if is moving up/down
		var range_end = -1
		if direction.y == 1:
			range_end = map.gridSize_y + 1
			
		for y in range(player_map_pos.y, range_end, direction.y):
			var entity = map.get_cell_entity(Vector2(player_map_pos.x, y))
			if entity and not entity is Player:
				spawn_beachball(entity)
				yield(map.get_parent().get_node("ProjectileGenerator"), "projectile_complete")
				entity.take_damage()
				return
	else:
		var range_end = -1
		if direction.x == 1:
			range_end = map.gridSize_x + 1
			
		for x in range(player_map_pos.x, range_end, direction.x):
			var entity = map.get_cell_entity(Vector2(x, player_map_pos.y))
			if entity and not entity is Player:
				spawn_beachball(entity)
				yield(map.get_parent().get_node("ProjectileGenerator"), "projectile_complete")
				entity.take_damage()
				return


func spawn_beachball(entity):
	player.emit_signal('projectile_spawn', player.position, entity.position)


func dispatch_dash():
	player.direction_function = funcref(self, "dash")


# TODO: make some particle effect or special move/animation tween function
# TODO: whooshy sound
func dash(direction: Vector2):
	var player_map_pos = map.world_to_map(player.position)
	if direction.x == 0:
	# if is moving up/down
		var range_end = -1
		if direction.y == 1:
			range_end = map.gridSize_y + 1
			
		for y in range(player_map_pos.y, range_end, direction.y):
			var entity = map.get_cell_entity(Vector2(player_map_pos.x, y))
			if entity and not entity is Player:
				#move toward entity, damage it
				player.move(map.map_to_world(Vector2(player_map_pos.x, y - direction.y)))
				entity.take_damage()
				return

			var tile = map.get_tile(player_map_pos.x, y)
			if tile and not tile.isPassable or not tile:
				player.move(map.map_to_world(Vector2(player_map_pos.x, y - direction.y)))
				return

	else:
		var range_end = -1
		if direction.x == 1:
			range_end = map.gridSize_x + 1
			
		for x in range(player_map_pos.x, range_end, direction.x):
			var entity = map.get_cell_entity(Vector2(x, player_map_pos.y))
			if entity and not entity is Player:
				#move toward entity, damage it
				player.move(map.map_to_world(Vector2(x - direction.x, player_map_pos.y)))
				entity.take_damage()
				return

			var tile = map.get_tile(x, player_map_pos.y)
			if tile and not tile.isPassable or not tile:
				player.move(map.map_to_world(Vector2(x - direction.x, player_map_pos.y)))
				return
	


func dispatch_trap():
	player.direction_function = funcref(self, "trap")


func trap(direction: Vector2):
	var trap = Trap.instance()
	var trapVector = map.map_to_world(map.world_to_map(player.position) + direction)
	trap.position = trapVector
	map.add_child(trap)


func dispatch_super_trap():
		player.direction_function = funcref(self, "super_trap")
	
	
func super_trap(direction: Vector2):
		var trap = SuperTrap.instance()
		var trapVector = map.map_to_world(map.world_to_map(player.position) + direction)
		trap.position = trapVector
		map.add_child(trap)


func water_attack():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		var tile = map.get_tilev(map.world_to_map(e.position))
		if not tile.isPassable:
			e.take_damage(2)


func bug_spray():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e.type == "wasp":
			e.take_damage()


func wait():
	player.emit_signal("game_tick")

