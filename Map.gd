extends TileMap
class_name Map

export var gridSize_x := 7
export var gridSize_y := 6

var grid = []

onready var used_rect = get_used_rect()
onready var astar = AStar2D.new()

var Exit = load("res://EXIT.tscn")
var exit = null

func _ready():
	setup()

func setup():
	randomize()
	var passable_tile_count = 0
	var connected_tile_count = 99
	while (not passable_tile_count == connected_tile_count):
		passable_tile_count = generateMap()
		# connected_tile_count = min(25, get_connected_tilesv(random_empty_coords()).size())
		connected_tile_count = min(500, get_connected_tilesv(random_empty_coords()).size())

	exit = Exit.instance()
	exit.position = random_empty_world_coords()
	add_child(exit)

var tileDict = {
	4: "water",
	5: "sand"
}

func generateMap():
	for node in get_children():
		if not node is Player:
			node.queue_free()

	astar.clear()
	grid = []
	var passable_tile_count = 0
	for x in range(gridSize_x):
		grid.append([])
		for y in range(gridSize_y):
			var tile = 5 #sand
			if randi() % 100 < 32:
				tile = 4 #water
			
			if tile == 5:
				passable_tile_count += 1;
				astar.add_point(get_tile_id(x, y), Vector2(x, y), 1)
			set_cell(x,y,tile,false,false,false,Vector2(1,1))
			grid[x].append(Tile.new(tileDict[tile],Vector2(x,y)))
	
	update_bitmask_region()
	return passable_tile_count


func get_tile(x,y):
	if is_in_bounds(x,y):
		return grid[x][y]
	else:
		return false


func get_tile_id(x, y):

	# Offset position of tile with the bounds of the tilemap
	# This prevents ID's of less than 0, if points are behind (0, 0)
	x = x - used_rect.position.x
	y = y - used_rect.position.y

	# Returns the unique ID for the point on the map
	return x + y * used_rect.size.x


func get_tile_idv(v:Vector2):
	return get_tile_id(v.x, v.y)

func get_tilev(v):
	return get_tile(v.x, v.y)


func get_trap(world_position: Vector2):
	for node in get_tree().get_nodes_in_group("traps"):
		if node.position == world_position:
			return node

	return null

func get_cell_entity(map_position):
	for node in get_tree().get_nodes_in_group("entities"):
		if not node.dead and (world_to_map(node.position) == map_position):
			return node


func get_column_entities(x):
	var entities = []
	for y in range(0, gridSize_y):
		var e = get_cell_entity(Vector2(x, y))
		if e:
			entities.append(e)
	return entities


func get_row_entities(y):
	var entities = []
	for x in range(0, gridSize_x):
		var e = get_cell_entity(Vector2(x, y))
		if e:
			entities.append(e)
	return entities

func is_in_bounds(x,y):
	var result = x >= 0 && x < gridSize_x && y >= 0 && y < gridSize_y
	return result


func is_in_boundsv(v):
	return is_in_bounds(v.x, v.y)


func is_exit(x,y):
	if exit:
		return exit.position == map_to_world(Vector2(x,y))


func is_exitv(v: Vector2):
	return is_exit(v.x, v.y)


func get_connected_tilesv(v):
	var connected_tiles = [get_tilev(v)]
	var frontier = [get_tilev(v)]
	while (frontier.size()):
		var current_tile = frontier.pop_back()
		var neighbors = get_adjacent_empty_tilesv(current_tile.position)
		for n in neighbors:
			astar.connect_points(get_tile_idv(current_tile.position), get_tile_idv(n.position), true)
			if not connected_tiles.has(n):
				connected_tiles.append(n)
				frontier.append(n)
	return connected_tiles


func random_empty_coords():
	var x = int(rand_range(0,gridSize_x))
	var y = int(rand_range(0,gridSize_y))
	
	if get_tile(x, y) and get_tile(x,y).isPassable and not get_cell_entity(Vector2(x, y)) and not is_exit(x,y):
		return Vector2(x, y)
	else:
		return random_empty_coords()


func update_entity_position(entity, direction):
	var old_pos_world = entity.position
	var old_pos_map = world_to_map(old_pos_world)
	var new_pos_map = old_pos_map + direction
	var new_pos_world = map_to_world(new_pos_map)
	
	var requestedTile = get_tilev(new_pos_map)
	var tileEntity = get_cell_entity(new_pos_map)
	
	if tileEntity and not tileEntity.dead:
		return tileEntity
		
	if entity.can_walk_on(requestedTile):
		return new_pos_world
	else: 
		return false


func get_new_world_position(entity, direction):
	var old_pos_world = entity.position
	var old_pos_map = world_to_map(old_pos_world)
	var new_pos_map = old_pos_map + direction
	var new_pos_world = map_to_world(Vector2(clamp(new_pos_map.x, 0, gridSize_x-1), clamp(new_pos_map.y, 0, gridSize_y-1)))
	return new_pos_world


func random_empty_world_coords():
	var coords = random_empty_coords()
	return map_to_world(coords)


func get_adjacent_tilesv(v):
	var tiles = []
	if is_in_boundsv(v + Vector2.UP):
		tiles.append(get_tilev(v + Vector2.UP))
	if is_in_boundsv(v + Vector2.DOWN):
		tiles.append(get_tilev(v + Vector2.DOWN))
	if is_in_boundsv(v + Vector2.LEFT):
		tiles.append(get_tilev(v + Vector2.LEFT))
	if is_in_boundsv(v + Vector2.RIGHT):
		tiles.append(get_tilev(v + Vector2.RIGHT))

	return tiles


func get_adjacent_empty_tilesv(v):
	var tiles = get_adjacent_tilesv(v)
	var filteredArray = []
	for tile in tiles:
		if tile.isPassable:
			filteredArray.append(tile)

	return filteredArray


func get_pathv(start: Vector2, end: Vector2):
	
	# Convert positions to cell coordinates
	var start_tile = world_to_map(start)
	var end_tile = world_to_map(end)

	# Determines IDs
	var start_id = get_tile_idv(start_tile)
	var end_id = get_tile_idv(end_tile)
	
		# Return null if navigation is impossible
#	if not astar.has_point(start_id) or not astar.has_point(end_id):
#		return null
	
		# Otherwise, find the map
	var path_map = astar.get_point_path(start_id, end_id)
	
	return path_map


class Tile:
	var name = null
	var isPassable = false
	var position
	func _init(_name, _pos):
		name = _name
		position = _pos
		isPassable = name == "sand"
