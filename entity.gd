extends Node2D

export(NodePath) var mapNode = null

var map
var hp = 1
var dead = false
var is_player = false
var has_been_moved = false
var type = "entity"

func init(initial_position, _map):
	position = initial_position
	map = _map


func _ready():
	if mapNode and not map:
		map = get_node(mapNode)
	pass


func take_damage(damage = 1):
	hp -= damage
	if hp < 1:
		dead = true
		die()


func die():
	queue_free()

func can_walk_on(tile):
	if has_been_moved:
		has_been_moved = false
		return tile
	else:
		return tile and tile.isPassable

