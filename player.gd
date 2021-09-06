extends RigidBody2D

export var headPosition:Vector2
var cellList = [0,1,2,3,2,1,3]
var cellNodes = []

# 0 = Undead Cell
# 1 = Red Cell
# 2 = Green Cell
# 3 = Blue Cell
enum CELL_TYPE {
	UNDEAD,
	RED,
	GREEN,
	BLUE,
}

var velocity = 300.0
var movingDir = Vector2(0,-1)
var cells = [ preload("res://cellUndead.tscn"),preload("res://cellRed.tscn"),preload("res://cellGreen.tscn"),preload("res://cellBlue.tscn")]

var shootNodes = []
var shootDir = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var i=0
	
	for cell in cellList:
		var node = cells[cell].instance()
		node.position += i* node.get_node("Sprite").texture.get_width() *( - movingDir)
		i+=1
		add_child(node)
		cellNodes.append(node)
		turningNo.append(0)

var turningPnts = []
var turningNo = []
func moveCell(i,cell,delta):
	if i==0:
		cell.position += velocity* delta * movingDir
	else:
		var turnPntIdx = turningNo[i] - 1
		if turningNo[i] > 0 :
			if cell.position.distance_to(turningPnts[turnPntIdx])>1.2*velocity*delta:
				var followDir:Vector2 = (turningPnts[turnPntIdx]-cellNodes[i].position).normalized()
				cell.position += velocity* delta *followDir
			else:
				cell.position = turningPnts[turnPntIdx]
				turningNo[i] -= 1
				if i == (cellNodes.size() -1):
					turningPnts.pop_back()
		else:
			var followDest:Vector2 = cellNodes[i-1].position-movingDir*cellNodes[i-1].get_node("Sprite").texture.get_width()
			var followDir:Vector2 = (followDest-cellNodes[i].position).normalized()
			cell.position += velocity* delta * followDir
		

var bulletVelocity=2000.0
func moveShoot(i,bullet,delta):
	#bullet.position+= bulletVelocity*shootDir[i]*delta
	# if bullet collide with cell tilemap,
	# add it to tilemap and destroy it
	var collision = bullet.move_and_collide(bulletVelocity*shootDir[i]*delta)
	if collision:
		if collision.collider is TileMap:
			var tilemap : TileMap = collision.collider
			
			var centerOffset = Vector2(shootNodes[i].get_node("Sprite").texture.get_width(), shootNodes[i].get_node("Sprite").texture.get_height()) / 2
			tilemap.add_new_cell(shootNodes[i].position, shootNodes[i].cell_type)
			# check elimination is viable or not
			tilemap.eliminate()
		shootNodes[i].queue_free()
		shootNodes.remove(i)
		shootDir.remove(i)
	elif bullet.position.distance_to(cellNodes[0].position)>=3000.0:
		shootNodes[i].queue_free()
		shootNodes.remove(i)
		shootDir.remove(i)
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
var head = 0
func _physics_process(delta):
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_up"):
		turningPnts.push_front(cellNodes[0].position)
		var i=0
		for cell in cellNodes:
			if i > 0:
				turningNo[i] += 1
			i+=1
		#print(pending_turnpoint)
		#ref_count.append(cellNodes.size()-1)
		
	
	if Input.is_action_pressed("move_left"):
		movingDir = Vector2(-1,0)
	elif Input.is_action_pressed("move_right"):
		movingDir = Vector2(1, 0)
	elif Input.is_action_pressed("move_up"):
		movingDir = Vector2(0,-1)
	elif Input.is_action_pressed("move_down"):
		movingDir = Vector2(0, 1)
	
	var i=0
	for cell in cellNodes:
		moveCell(i,cell,delta)
		i+=1	
		
	if Input.is_action_just_released("shoot") and cellNodes.size()>1:
		shootNodes.append(cellNodes[0])
		shootDir.append(movingDir)
		cellNodes.remove(0)
		head=0
		
	i=0		
	for bullet in shootNodes:
		moveShoot(i,bullet,delta)
		i+=1
	
	if Input.is_action_just_released("swap") and cellNodes.size()>2:
		var toSwap = (head +1)%cellNodes.size()
		var tmp = cellNodes[head]
		var tmpPos = cellNodes[toSwap].position
		cellNodes[head]=cellNodes[toSwap]
		cellNodes[head].position = tmp.position
		cellNodes[toSwap]=tmp
		cellNodes[toSwap].position = tmpPos
		head+=1
		head%=cellNodes.size()
	headPosition = cellNodes[0].global_position
	pass
