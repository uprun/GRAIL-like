class_name Symbol_Drawn extends Object

var lines = []
var compressed_lines = []

func prepare_rescaled_lines():
	var first_line = self.lines[0]
	var top = first_line[0]
	var bottom = first_line[0]
	var left = first_line[0]
	for line in self.lines:
		for point in line:
			if point.y > bottom.y:
				bottom = point
			if point.y < top.y:
				top = point
			if point.x < left.x:
				left = point
	print("center left.x: ", left.x, " top.y: ", top.y, " bottom.y: ", bottom.y)
	var height = (bottom.y - top.y)
	var scale =  1.0 
	if (height > 40): # prevent scaling of small letters - usually punctuations
		scale = height / 40.0 
	print("scale :", scale)
	for line in self.lines:
		self.compressed_lines.push_back([])
		var previous_point = null
		for point in line:
			var x = (point.x - left.x) / scale
			var y = (point.y - top.y) / scale
			var to_add = Vector2(x, y)
			if previous_point == null:
				previous_point = to_add
			self.add_a_lot_of_points_in_between(previous_point, to_add)
			self.compressed_lines.back().push_back(to_add)
		
	
func add_a_lot_of_points_in_between(start: Vector2, finish: Vector2):
	var direction = finish - start
	var length_of_direction = direction.length()
	if length_of_direction <= 1:
		return
	
	for i in range(0, length_of_direction, 0.7):
		var to_add = start + (direction * i / length_of_direction)
		self.compressed_lines.back().push_back(to_add)
	
func compare_internal(two: Symbol_Drawn):
	var one = self
	var matched_points = 0
	var total_points = 0
	for line in one.compressed_lines:
		for point in line:
			total_points += 1
			for compare_line in two.compressed_lines:
				for compare_point in compare_line:
					if (compare_point - point ).length() < 2.0:
						matched_points += 1
						break
	var match_ratio = matched_points * 100.0 / total_points
	return match_ratio
	

func double_compare(two: Symbol_Drawn):
	var match_ratio = self.compare_internal( two)
	#reverse comparison
	match_ratio = min(match_ratio, two.compare_internal(self))
	return match_ratio
