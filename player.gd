extends RigidBody2D

var cellList = [0,1,2,3,2,1,3]
var cellNodes = []

# 0 = Undead Cell
# 1 = Red Cell
# 2 = Green Cell
# 3 = Blue Cell

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
		node.position += i* node.texture.get_width() * - movingDir
		i+=1
		add_child(node)
		cellNodes.append(node)
		reachedTurning.append(true)
		turningPnts.append(node.position)

var turningPnts =[]
var reachedTurning = []
func moveCell(i,cell,delta):
	if i==0:
		cell.position += velocity* delta * movingDir
	else:
		
		if not reachedTurning[i] and cell.position.distance_to(turningPnts[i])>=velocity*delta:
			var followDir:Vector2 = (turningPnts[i]-cellNodes[i].position).normalized()
			#print(i,followDir)
			cell.position += velocity* delta *followDir
		else:
			if not reachedTurning[i]:
				reachedTurning[i] = true
				cell.position = turningPnts[i]
				pass
			var followDest:Vector2 = cellNodes[i-1].position-movingDir*cellNodes[i-1].texture.get_width()
			var followDir:Vector2 = (followDest-cellNodes[i].position)
			cell.position += velocity* delta * followDir.normalized()
		

var bulletVelocity=2000.0
func moveShoot(i,bullet,delta):
	bullet.position+= bulletVelocity*shootDir[i]*delta
	if bullet.position.distance_to(cellNodes[0].position)>=3000.0:
		shootNodes[i].queue_free()
		shootNodes.remove(i)
		shootDir.remove(i)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
var head = 0
func _process(delta):
	
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_down") or Input.is_action_pressed("move_up"):
		for i in range(cellNodes.size()):
			if i>0:
				var r = cellNodes.size()-i
			#	print(r)
				turningPnts[r]=cellNodes[0].position
			else:
				turningPnts[0]=cellNodes[0].position
			reachedTurning[i]=false
	
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
	pass
