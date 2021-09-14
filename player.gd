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
var cellsBullets = [ preload("res://cellUndeadBullet.tscn"),preload("res://cellRedBullet.tscn"),preload("res://cellGreenBullet.tscn"),preload("res://cellBlueBullet.tscn")]
var cells = [ preload("res://cellUndead.tscn"),preload("res://cellRed.tscn"),preload("res://cellGreen.tscn"),preload("res://cellBlue.tscn")]
var shootNodes = []
var shootDir = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var i=0
	
	for cell in cellList:
		var node = cellsBullets[cell].instance()
		node.position += i* node.get_node("Sprite").texture.get_width() *( - movingDir)
		node.get_node("CollisionShape2D").hide()
		
		i+=1
		add_child(node)
		cellNodes.append(node)
		turningNo.append(0)

var turningPnts = []
var turningNo = []
func moveCell(i,cell,delta):
	var turnPntIdx = turningNo[i] - 1
	if turningNo[i] > 0 :
		if cell.position.distance_to(turningPnts[turnPntIdx])>velocity*delta:
			var followDir:Vector2 = (turningPnts[turnPntIdx]-cellNodes[i].position).normalized()
			cell.position += velocity* delta *followDir
		else:
			var total_moving_amt = velocity * delta
			var amt1 = cell.position.distance_to(turningPnts[turnPntIdx])
			var dir1 = (turningPnts[turnPntIdx]-cell.position).normalized()
			var dir2 = (cellNodes[i-1].position-cell.position).normalized()
		#	cell.position = turningPnts[turnPntIdx]
			#if (total_moving_amt > amt1):
			#	cell.position += (total_moving_amt-amt1)*dir2
			cell.position += velocity* delta *dir2
			
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
		#if collision.collider is TileMap:
		#	var tilemap : TileMap = collision.collider
		var tilemap : TileMap = get_node("../Cells")	
		var centerOffset = Vector2(shootNodes[i].get_node("Sprite").texture.get_width(), shootNodes[i].get_node("Sprite").texture.get_height()) / 2
			#x=  get_parent().get_node("Camera2D").to_global(shootNodes[i].position)
		var collision_pnt = collision.position
		var hit_pnt = tilemap.world_to_map(collision_pnt)
		if tilemap.get_cellv(hit_pnt):
			tilemap.add_new_cell(hit_pnt-shootDir[i],shootNodes[i].cell_type)
			# check elimination is viable or not
			tilemap.eliminate(hit_pnt-shootDir[i])
			#tilemap.fall(hit_pnt-shootDir[i], 0.6)
		else:
			var player_global_position =  to_global(shootNodes[i].position)
			var cell_coord = tilemap.world_to_map(player_global_position)
			tilemap.add_new_cell(cell_coord, shootNodes[i].cell_type)
			# check elimination is viable or not
			tilemap.eliminate(cell_coord)
			#tilemap.fall(cell_coord, 0.6)
		
		
		shootNodes[i].queue_free()
		shootNodes.remove(i)
		shootDir.remove(i)
	elif bullet.position.distance_to(cellNodes[0].position)>=3000.0:
		shootNodes[i].queue_free()
		shootNodes.remove(i)
		shootDir.remove(i)
		

func addTurningNo():
	var i=0
	for cell in cellNodes:
		if i > 0:
			turningNo[i] += 1
		i+=1
# Called every frame. 'delta' is the elapsed time since the previous frame.
var head = 1
func _physics_process(delta):
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_up"):
		
		if turningPnts.size()>0:
			if cellNodes[0].position != turningPnts[0]:
				turningPnts.push_front(cellNodes[0].position)
				addTurningNo()
		else:
			turningPnts.push_front(cellNodes[0].position)
			addTurningNo()
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
		var level:TileMap = get_node("../Level")
		print(level.world_to_map(Vector2(0,-1)))
		print(level.world_to_map(Vector2(0,128)))
	headPosition = cellNodes[0].global_position
	pass

