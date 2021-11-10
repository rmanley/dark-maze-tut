extends Node

class_name Pathfinder

var grid_map: GridMap = null
var nav_id = -1
var a_star: AStar = null

var nav_points = []
var indices = {}

func _init(grid_map: GridMap, nav_id: int):
	self.grid_map = grid_map
	self.nav_id = nav_id
	a_star = AStar.new()
	
	# Set the walkable tiles
	for cell in grid_map.get_used_cells():
		var id = grid_map.get_cell_item(cell.x, cell.y, cell.z)
		if id == nav_id:
			var point = Vector3(cell.x, cell.y, cell.z)
			nav_points.append(point)
			# astar links nav points together via indices
			var index = indices.size() # unique index for astar
			indices[point] = index
			a_star.add_point(index, point)
			
	# connect each tile
	for point in nav_points:
		var index = get_point_index(point)
		var relative_points = PoolVector3Array([
			# check forward, backward, and sides
			Vector3(point.x + 1, point.y, point.z),
			Vector3(point.x - 1, point.y, point.z),
			Vector3(point.x, point.y, point.z + 1),
			Vector3(point.x, point.y, point.z - 1)
		])
		
		for relative_point in relative_points:
			var relative_index = get_point_index(relative_point)
			if relative_index == null:
				continue
			if a_star.has_point(relative_index):
				a_star.connect_points(index, relative_index)


func find_path(start, target):
	var world_path = []
	
	var grid_start = grid_map.world_to_map(start)
	var grid_end = grid_map.world_to_map(target)
	var grid_start_index = get_point_index(grid_start)
	var grid_end_index = get_point_index(grid_end)
	if grid_start_index == null or grid_end_index == null:
		return world_path
	var a_star_path = a_star.get_point_path(grid_start_index, grid_end_index)
	
	for point in a_star_path:
		world_path.append(grid_map.map_to_world(point.x, point.y, point.z))
		
	return world_path


func get_point_index(point):
	if indices.has(point):
		return indices[point]
	return null
