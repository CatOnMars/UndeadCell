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
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
