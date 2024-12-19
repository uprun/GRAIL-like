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
	var scale = (bottom.y - top.y) / 40.0 
	print("scale :", scale)
	for line in self.lines:
		self.compressed_lines.push_back([])
		for point in line:
			var x = (point.x - left.x) / scale
			var y = (point.y - top.y) / scale
			self.compressed_lines.back().push_back(Vector2(x, y))
			
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
	

