extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cell_type = Global.CELL_TYPE.UNDEAD

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var fallingEnabled = true
func enableFalling(on=true):
	fallingEnabled = on
func getFallingEnabled():
	return fallingEnabled
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
