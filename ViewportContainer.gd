extends ViewportContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var light_pos;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var player = get_node("Viewport/Player")
	if player:
		light_pos = player.headPosition
		material.set_shader_param("light_pos",Vector2(0.5,0.5))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
