extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var cells:Dictionary = { "undead": preload("res://cellUndead.tscn"),
"red":preload("res://cellRed.tscn"), "green": preload("res://cellGreen.tscn"),
"blue": preload("res://cellBlue.tscn")}
# Called when the node enters the scene tree for the first time.
var cellsPresent:Dictionary = {}
func _ready():
	var cell_coords = get_used_cells()
	for coord in cell_coords:
		var cell_type = get_cellv(coord)
		var cell_name = tile_set.tile_get_name(cell_type)
		if cell_name in cells:
			var cell_inst = cells[cell_name].instance()
			cell_inst.position = map_to_world(coord) + cell_inst.get_node("Sprite").texture.get_size()/2.0
			add_child(cell_inst)
			cellsPresent[coord] = cell_inst
	pass

func test(position):
	print(world_to_map(position))
	
func add_new_cell(cellCoord, type):
	print(cellCoord) 
	set_cellv(cellCoord, type)
	var cell_name = tile_set.tile_get_name(type)
	var cell_inst = cells[cell_name].instance()
	cell_inst.position = map_to_world(cellCoord) + cell_inst.get_node("Sprite").texture.get_size()/2.0
	add_child(cell_inst)
	cellsPresent[cellCoord] = cell_inst

func fadeOut(coord,duration):
	print("fadeOut",coord)
	var mat=cellsPresent[coord].get_node("Sprite").get_material()
	mat.set_shader_param("r",0.4)
	var alpha=duration
	while duration>0:
		yield(get_tree(),"idle_frame")
		duration-=get_process_delta_time()
		mat.set_shader_param("r",duration/alpha)
	set_cellv(coord, -1)
	cellsPresent[coord].queue_free()
	cellsPresent.erase(coord)
	#mat.set_shader_param("r",0.4)
	pass
	
	
func eliminate():
	# DFS all activated cells
	var cell_coords = get_used_cells()
	var eList = {}
	for coord in cell_coords:
		for cord in dfs(coord):
			eList[cord] = cord
	for coord in eList:
		if (get_cellv(coord)!=-1):
			fadeOut(coord,0.3)
	pass
	#fall()
	
var BOUND_Y = 3
class YCoordSorter:
	static func sort_descending(a, b):
		if a[1] > b[1]:
			return true
		return false
func fall():
	var cell_coords = get_used_cells()
	cell_coords.sort_custom(YCoordSorter, 'sort_descending')
	print(cell_coords)
	var moveDownList = []
	for coord in cell_coords:
		if coord.y >= BOUND_Y or get_cellv(coord) > 3:
			continue
		var newCoord = coord
		while  get_cellv(newCoord+Vector2(0, 1) ) == -1 and (newCoord+Vector2(0, 1) ).y <= BOUND_Y:
			newCoord += Vector2(0, 1)
			continue
		moveDownList.append([coord, newCoord])
	for coordPair in moveDownList:
		var coord =coordPair[0]
		var newCoord =coordPair[1]
		var cellType = get_cellv(coord)
		set_cellv(coord, -1)
		set_cellv(newCoord, cellType)
		
func dfs(origin):
	
	var targetCell = get_cellv(origin)
	if targetCell == -1:
		return []
	var yDirs = [[0, 1], [0, -1]]
	var xDirs = [[1, 0], [-1, 0]]
	var yList = []
	var xList = []
	# for each direction, elimination only occurs when
	# more than or equal to 3 same cells(include undead cell) 
	if origin.x == -41 and origin.y == 31:
		print("found")
	for ydir in yDirs:
		var np = origin + Vector2(ydir[0], ydir[1])
		while get_cellv(np) == targetCell or get_cellv(np) == Global.CELL_TYPE.UNDEAD:
			yList.append(np)
			np += Vector2(ydir[0], ydir[1])
	yList.append(origin)
	for xdir in xDirs:
		var np = origin + Vector2(xdir[0], xdir[1])
		while get_cellv(np) == targetCell or get_cellv(np) == Global.CELL_TYPE.UNDEAD:
			xList.append(np)
			np += Vector2(xdir[0], xdir[1])
	xList.append(origin)
	if len(yList) < 3 and len(xList) < 3:
		return []
	elif len(yList) < 3:
		return xList
	else:
		return yList
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
