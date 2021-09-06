extends RigidBody2D

export var headPosition:Vector2
var cellList = [0,1,2,3]
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
			#x=  get_parent().get_node("Camera2D").to_global(shootNodes[i].position)
			var player_global_position
			player_global_position =  to_global(shootNodes[i].position)
			tilemap.add_new_cell(player_global_position, shootNodes[i].cell_type)
			
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
var head = 1
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
	
	var collision = cellNodes[0].move_and_collide(velocity* delta * movingDir)
	if not collision:
		for idx in range(1,cellNodes.size()):
			moveCell(idx,cellNodes[idx],delta)	
		
	if Input.is_action_just_released("shoot") and cellNodes.size()>1:
		shootNodes.append(cellNodes[1])
		shootDir.append(movingDir)
		for idx in range(2,cellNodes.size()):
			cellNodes[idx].position=cellNodes[idx-1].position
		cellNodes[1].position = cellNodes[0].position+velocity*delta*movingDir
		cellNodes.remove(1)
		head=1
		
	var i=0		
	for bullet in shootNodes:
		moveShoot(i,bullet,delta)
		i+=1
	
	if Input.is_action_just_released("swap") and cellNodes.size() > 2:
		var toSwap = (head +1)%cellNodes.size()
		if toSwap == 0:
			toSwap = 1
		var tmp = cellNodes[head]
		var tmpPos = cellNodes[toSwap].position
		cellNodes[head]=cellNodes[toSwap]
		cellNodes[head].position = tmp.position
		cellNodes[toSwap]=tmp
		cellNodes[toSwap].position = tmpPos
		head+=1
		head%=cellNodes.size()
		if head == 0:
			head = 1
	headPosition = cellNodes[0].global_position
	pass
