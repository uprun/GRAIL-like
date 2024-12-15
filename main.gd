extends Node2D


var point1 : Vector2 = Vector2(0, 0)
var width : int = 5
var color : Color = Color.GREEN

var _point2 : Vector2

var lines = []

var current_line = []
var current_line_length = 0

class Sub_Path:
	var Start: Vector2
	var Finish: Vector2
	var Id: int
	var Intersecting: bool
	
class Symbol_Drawn:
	var Sub_paths = []
	
var all_sub_paths = []

func are_intersecting(first: Sub_Path, second: Sub_Path):
	if abs(first.Id - second.Id) < 10:
		return false
	return first.Start.distance_to(second.Start) < 20

func analyze_sub_path(sub: Sub_Path):
	for s in all_sub_paths:
		var c =  s as Sub_Path
		if c.Id == sub.Id:
			continue
		if are_intersecting(c, sub):
			c.Intersecting = true
			sub.Intersecting = true

func add_sub_path(start, finish):
	var sub = Sub_Path.new()
	sub.Start = start
	sub.Finish = finish
	sub.Id = len(all_sub_paths)
	sub.Intersecting = false
	analyze_sub_path(sub)
	all_sub_paths.push_back(sub)


func _process(_delta):
	var mouse_position = get_viewport().get_mouse_position()
	if Input.is_mouse_button_pressed( 1 ):
		if current_line.is_empty():
			
			current_line_length = 0
			add_sub_path(mouse_position, mouse_position)
			current_line.push_back(mouse_position)
		else:
			var last_point = current_line.back()
			if mouse_position != last_point:
				current_line.push_back(mouse_position)
				add_sub_path(last_point, mouse_position)
				var dist  = last_point.distance_to(mouse_position)
				current_line_length += dist
				print (dist)
				
	else:
		if not current_line.is_empty():
			lines.push_back(current_line)
			current_line = []
	queue_redraw()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func my_draw_polyline(line: Array):
	if line.is_empty():
		pass
	if len(line) > 1:
		draw_polyline(line, color, width)
	else:
		draw_circle(line.back(), width, color)
		
func my_draw_sub(sub: Sub_Path):
	var active_color = color
	if sub.Intersecting:
		active_color = Color.BLUE
	if sub.Start.distance_to(sub.Finish) > 1:
		draw_line(sub.Start, sub.Finish, active_color, width)
	else:
		draw_circle(sub.Start, width, active_color)

func _draw():
	for sub in all_sub_paths:
		my_draw_sub(sub)
