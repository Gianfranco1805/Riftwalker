extends Node2D


var Room = preload("res://room.tscn")
var Player = preload("res://player.tscn")
@onready var map = $TileMap
@onready var mapLayer = $TileMap/grass
@onready var waterLayer = $TileMap/water
@onready var corridorLayer = $TileMap/corridor
var Enemy = preload("res://scenes/Raydel.tscn")

var tileSize = 32
var numberOfRooms = 9
var minSize = 10
var maxSize = 20
var horizontalSpread = 500
var cull = 0.5

var path # A* pathfiunding object

var start_room = null
var end_room = null
var player = null

var dirtTiles = []



	
func _ready():
	randomize()
	make_many_rooms()
	await get_tree().create_timer(2).timeout
	find_start_room()
	find_end_room()
	_draw()
var roomPositions = []

func make_many_rooms():
	for i in range(numberOfRooms):
		var startPosition = Vector2(randf_range(-horizontalSpread, horizontalSpread), 0)
		var newRoom = Room.instantiate()
		var width = minSize + randi() % (maxSize - minSize)
		var height = minSize + randi() % (maxSize - minSize)
		newRoom.make_room(startPosition, Vector2(width, height) * tileSize)
		$Rooms.add_child(newRoom)
	#wait for the rooms to spread
	await get_tree().create_timer(1.1).timeout
	#cull rooms
	
	for room in $Rooms.get_children():
		if randf() < cull:
			room.queue_free()
		else:
			room.freeze = true
			roomPositions.append(Vector2(room.position.x, room.position.y))
	await get_tree().process_frame
	#generate a MST
	path = find_mst(roomPositions)
	
	
func _draw():
	var default_font = ThemeDB.fallback_font
	var default_font_size = ThemeDB.fallback_font_size
	#if start_room:
		#draw_string(default_font, start_room.position, "Start", HORIZONTAL_ALIGNMENT_LEFT, -1 ,125, Color(1, 1, 1))
	#if end_room:
		#draw_string(default_font, end_room.position, "End", HORIZONTAL_ALIGNMENT_LEFT, -1 , 125, Color(1,1,1))
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(0, 1, 0, 1), false)
	if path:
		for p in path.get_point_ids():
			for c in path.get_point_connections(p):
				var pp = path.get_point_position(p)
				var cp = path.get_point_position(c)
				draw_line(Vector2(pp.x, pp.y), Vector2(cp.x, cp.y), Color(1, 1, 0, 1), 15, true)

func _process(_delta):
	queue_redraw()

func _input(event):
	if event.is_action_pressed("ui_select"):
		for n in $Rooms.get_children():
			n.queue_free()
		path = null
		start_room = null
		end_room = null
		make_many_rooms()
	if event.is_action_pressed('ui_focus_next'):
		make_map()
	if event.is_action_pressed('ui_cancel'):
		player = Player.instantiate()
		add_child(player)
		player.position = start_room.position
	if event.is_action_pressed("ui_accept"):
		for i in $Rooms.get_children():
			#roomPositions.append(Vector2(i.position.x, i.position.y))
			make_enemy_spawn(Vector2(i.position.x, i.position.y))
		
		

			#print(roomPositions)
			#for j in roomPositions:
				#var enemySpawn = Enemy.instantiate()
				#add_child(enemySpawn)
				#enemySpawn.apply_floor_snap()
		
		
		

func find_mst(nodes):
	#Prim's algorithm
	path = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	
	#repeat until no more node remains
	while nodes:
		var minD = INF #minimum distance so far
		var minP = null #position of that node
		var p = null #current position
		#loop through all points in the path
		for p1 in path.get_point_ids():
			var p3
			p3 = path.get_point_position(p1)
			#loop though the remaining nodes
			for p2 in nodes:
				if p3.distance_to(p2) < minD:
					minD = p3.distance_to(p2)
					minP = p2
					p = p3
		var n = path.get_available_point_id()
		path.add_point(n, minP)
		path.connect_points(path.get_closest_point(p), n)
		nodes.erase(minP)
	return path

func make_map():
	#created tilemap from rooms and path
	map.clear()
	
	#fill tielemap with walls and then carve with empty rooms
	var fullRectangle = Rect2()
	for room in $Rooms.get_children():
		
		var r = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)
		fullRectangle = fullRectangle.merge(r)
	var topLeft = map.local_to_map(fullRectangle.position)
	var bottomRight = map.local_to_map(fullRectangle.end)
	for x in range(topLeft.x, bottomRight.x):
		for y in range(topLeft.y, bottomRight.y):
			#waterLayer.set_cell(0, Vector2i(x, y), 13, Vector2i(0,0), 0)
			BetterTerrain.set_cell(waterLayer,Vector2i(x,y),1)
	
	#carve the rooms
	var corridors = [] #one corridor per connection
	for room in $Rooms.get_children():
		
		var s = (room.size / tileSize).floor()
		var ul = (room.position / tileSize).floor() - s
		for x in range(2, s.x * 3 - 1):
			for y in range(2, s.y * 3 - 1):
				
				#map.set_cell(0, Vector2i(ul.x + x, ul.y + y), 12, Vector2i(0, 0), 0)
				BetterTerrain.set_cell(mapLayer,Vector2i(ul.x + x, ul.y + y),0)
				BetterTerrain.update_terrain_cell(mapLayer,Vector2i(ul.x + x, ul.y + y))
				
				#map.set_cells_terrain_connect(0, roomPositions, 1, 0, bool = true)
				#map.set_cell(0, Vector2i(ul.x + x +1, ul.y + y + 1), 0 , Vector2i(1 , 4))
				#map.set_cell(0, Vector2i(ul.x + x - 1, ul.y + y - 1), 0, Vector2i(1,4))
		#for i in range(room.position.x - 1, bottomRight.x) :
			#for j in range(room.position. x - 1 , bottomRight.y):
				#map.set_cell(0, Vector2i(i , j), 0, Vector2i(1, 4), 0)
				
				
				
				
		#carve the connection
		var p = path.get_closest_point(Vector2(room.position.x, room.position.y))
		for conn in path.get_point_connections(p):
			if not conn in corridors:
				var start = map.local_to_map(Vector2(path.get_point_position(p).x, path.get_point_position(p).y))
				var end = map.local_to_map(Vector2(path.get_point_position(conn).x, path.get_point_position(conn).y))
				carve_path(start, end)
			corridors.append(p)
			room.get_node("CollisionShape2D").disabled = true
		

func carve_path(pos1, pos2):
	#carve a pth between two points
	var xDiff = sign(pos2.x - pos1.x)
	var yDiff = sign(pos2.y - pos1.y)
	if xDiff == 0:
		xDiff = pow(-1.0, randi() % 2)
	if yDiff == 0:
		yDiff = pow(-1.0, randi() % 2)
	#choose either x and then y or y and then x
	var xY = pos2
	var yX = pos1
	if(randi() % 2) > 0:
		xY = pos2
		yX = pos1
	for x in range(pos1.x, pos2.x, xDiff):
		BetterTerrain.set_cell(mapLayer,Vector2i(x, xY.y),0)
		BetterTerrain.update_terrain_cell(mapLayer,Vector2i(x,xY.y))
		BetterTerrain.set_cell(mapLayer,Vector2i(x, xY.y + yDiff),0) #widen the corridors
		BetterTerrain.update_terrain_cell(mapLayer,Vector2i(x, xY.y + yDiff))
		BetterTerrain.set_cell(mapLayer,Vector2i(x, xY.y - yDiff),0)
		BetterTerrain.update_terrain_cell(mapLayer,Vector2i(x, xY.y - yDiff))

		
	for y in range(pos1.y, pos2.y, yDiff):
		BetterTerrain.set_cell(mapLayer,Vector2i(yX.x, y),0)
		BetterTerrain.update_terrain_cell(mapLayer,Vector2i(yX.x, y))
		BetterTerrain.set_cell(mapLayer,Vector2i(yX.x + xDiff, y ),0)
		BetterTerrain.update_terrain_cell(mapLayer,Vector2i(yX.x + xDiff, y))
		BetterTerrain.set_cell(mapLayer,Vector2i(yX.x - xDiff, y),0)
		BetterTerrain.update_terrain_cell(mapLayer,Vector2i(yX.x - xDiff, y))

func find_start_room():
	var min_x = INF 
	for room in $Rooms.get_children():
		if room.position.x < min_x: 
			start_room = room
			min_x = room.position.x
func find_end_room():
	var max_x = -INF
	for room in $Rooms.get_children():
		if room.position.x > max_x:
			end_room = room
			max_x = room.position.x

func make_enemy_spawn(pos):
	var enemySpawn = Enemy.instantiate()
	add_child(enemySpawn)
	enemySpawn.position = pos
	
		#for j in roomPositions:
			
		
	
