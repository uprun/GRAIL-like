extends Node2D


const Sub_Path = preload("res://Sub_Path.gd")
const Symbol_Drawn = preload("res://Symbol_Drawn.gd")

var width : int = 5
var color : Color = Color.GREEN


var lines = []

var current_line = []
var current_line_length = 0


	


func draw_compressed_symbol(symbol: Symbol_Drawn, offset: Vector2, color):
	for line in symbol.compressed_lines:
		var previous = null
		var initial = null
		for point in line:
			if initial == null:
				initial = point
			if previous != null:
				draw_line(previous + offset, point + offset, color, width)
			previous = point
		if (previous - initial).length() < 2:
			draw_circle(initial + offset, width, color)

var stored_symbols = []
var all_sub_paths = []

func add_sub_path(start, finish):
	var sub = Sub_Path.new()
	sub.Start = start
	sub.Finish = finish
	sub.Id = len(all_sub_paths)
	sub.Intersecting = false
	all_sub_paths.push_back(sub)

func _unhandled_input(event):
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
				
	else:
		if not current_line.is_empty():
			lines.push_back(current_line)
			current_line = []

var golden_match = []





func _process(_delta):
	queue_redraw()
	if compare_index == null:
		compare_index = 0
	if stored_symbols.size() <= compare_index:
		compare_index = null
		if symbol_to_compare != null and max_matching_ratio < 85:
			stored_symbols.push_back(symbol_to_compare)
			golden_match.push_back(false)
		symbol_to_compare = null
		max_matching_ratio = 0.0
		
		
	if compare_index != null and symbol_to_compare != null:
		var test = stored_symbols[compare_index] as Symbol_Drawn
		
		var match_ratio = symbol_to_compare.double_compare(test)
		
		if match_ratio > 85:
			golden_match[compare_index] = true
		else:
			golden_match[compare_index] = false
		compare_index += 1
		
		print( "match ratio: ",  match_ratio)
		max_matching_ratio = max(match_ratio, max_matching_ratio)


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
		
	var offset = Vector2(50,120)
	for i in len(stored_symbols):
		var symbol = stored_symbols[i]
		draw_compressed_symbol(symbol, offset, Color.GREEN)
		if symbol_to_draw_over != null:
			if golden_match[i]:
				draw_compressed_symbol(symbol_to_draw_over, offset, Color.GOLD)
			else:
				draw_compressed_symbol(symbol_to_draw_over, offset, Color.MAGENTA)
		offset.x += 150


func _on_button_pressed():
	var drawn_symbol = Symbol_Drawn.new()
	drawn_symbol.lines = lines
	lines = []
	all_sub_paths = []
	if drawn_symbol.lines.size() > 0:
		drawn_symbol.prepare_rescaled_lines()
		stored_symbols.push_back(drawn_symbol)
		golden_match.push_back(false)


func _on_button_button_down():
	pass # Replace with function body.


func _on_compare_button_down():
	pass # Replace with function body.


var compare_index = null
var symbol_to_compare: Symbol_Drawn = null
var max_matching_ratio = 0.0
var symbol_to_draw_over = null
func _on_compare_pressed():
	var drawn_symbol = Symbol_Drawn.new()
	drawn_symbol.lines = lines
	lines = []
	all_sub_paths = []
	if drawn_symbol.lines.size() > 0:
		drawn_symbol.prepare_rescaled_lines()
		print()
		var save_path := "user://player_data.json"
		
		var file_access := FileAccess.open(save_path, FileAccess.WRITE)
		if not file_access:
			print("An error happened while saving data: ", FileAccess.get_open_error())
			return
		
		var a = JSON.stringify(drawn_symbol.compressed_lines, "    ")
		file_access.store_line(a)
		
		file_access.close()
		
		var file_read = FileAccess.open(save_path, FileAccess.READ)
		if not file_read:
			print("An error happened while saving data: ", FileAccess.get_open_error())
			return
		var stored_json = file_read.get_as_text()
		file_read.close()
		
		
		
		
		var global_path = ProjectSettings.globalize_path(save_path)
		#OS.shell_show_in_file_manager(global_path)
		
		symbol_to_compare = drawn_symbol
		symbol_to_draw_over = drawn_symbol
		compare_index = null
