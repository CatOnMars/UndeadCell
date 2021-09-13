extends Polygon2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var X_CELLS = 0
var Y_CELLS = 0

var topLeftCell = Vector2.ZERO
var buttomRightCell  = Vector2.ZERO
var cellUsedMap = {}
onready var tilemap = get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	var topLeft = Vector2.ZERO
	var buttomRight = Vector2.ZERO
	
	var cellSize = tilemap.cell_size
	if len(polygon) > 0:
		topLeft = to_global(polygon[0])
		buttomRight = to_global(polygon[2])
		X_CELLS = int(abs(topLeft.x - buttomRight.x) / cellSize.x)
		Y_CELLS =int( abs(topLeft.y - buttomRight.y) / cellSize.y)
	topLeftCell = tilemap.world_to_map(topLeft)
	buttomRightCell = topLeftCell+Vector2(X_CELLS, Y_CELLS)
	print(topLeftCell)
	print(buttomRightCell)
	updateCellUsedMap()
	pass # Replace with function body.

func hasCoordinate(coord):
	if topLeftCell.x <= coord.x and coord.x <= buttomRightCell.x and topLeftCell.y <= coord.y and coord.y <= buttomRightCell.y:
		return true
	return false
func getEmptyCellsInRect():
	var ret = []
	for cell in cellUsedMap:
		if not cellUsedMap[cell]:
			ret.append(cell)
	return ret
func getUsedCellsInRect():
	var ret = []
	for cell in cellUsedMap:
		if cellUsedMap[cell]:
			ret.append(cell)
	return ret
func updateCellUsedMap():
	for i in range(X_CELLS):
		for j in range(Y_CELLS):
			var cellCoord = topLeftCell + Vector2(i, j)
			if get_parent().get_cellv(cellCoord) == -1:
				cellUsedMap[cellCoord] = false
			else:
				cellUsedMap[cellCoord] = true
	pass
class YCoordSorter:
	static func sort_descending(a, b):
		if a[1] > b[1]:
			return true
		return false
	
func getMoveDownCellList():
	# search action only applies to empty cell
	#if tilemap.get_cellv(coord) >= 0:
	#	return []
	var ret = []
	var distance = 0
	var emptyList = getEmptyCellsInRect()
	var track = []
	for i in range(X_CELLS):
		track.append(false)
	emptyList.sort_custom(YCoordSorter, 'sort_descending')
	for coord in emptyList:
		if track[coord.x - topLeftCell.x]:
			continue
		var cur = coord
		distance = 0
		while cur.y >= topLeftCell.y:
			if tilemap.get_cellv(cur) == -1:
				distance += 1
			else:
				ret.append([cur, Vector2(cur.x, cur.y+distance)])
			cur += Vector2(0, -1)
		track[coord.x - topLeftCell.x] = true
	return ret
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
