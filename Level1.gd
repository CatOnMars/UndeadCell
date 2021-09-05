extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func test(position):
	print(world_to_map(position))
func add_new_cell(position, type):
	var cellCoord = world_to_map(position)
	print(cellCoord)
	set_cellv(cellCoord, type)
func eliminate():
	# DFS all activated cells
	var cell_coords = get_used_cells()
	var eList = []
	for coord in cell_coords:
		eList.append_array(dfs(coord))
	for coord in eList:
		set_cellv(coord, -1)
	pass
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
