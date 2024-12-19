class_name Symbol_Drawn extends Object

var lines = []
var compressed_lines = []

func prepare_rescaled_lines():
	var first_line = self.lines
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
