extends KinematicBody


const SPEED = 2.0
var target: Spatial = null
var vel = Vector3()
var path_finder: Pathfinder = null
var path = null


func _ready():
	set_physics_process(false)
	path_finder = Pathfinder.new(get_parent(), 1)
	
	var timer = Timer.new()
	timer.wait_time = 1
	add_child(timer)
	timer.connect("timeout", self, 'find_path_timer')
	timer.start()


func _physics_process(_delta):
	look_at(target.global_transform.origin, Vector3.UP)
	
	if not path.empty():
		_move_along_path(path)


func _move_along_path(path: PoolVector3Array):
	if global_transform.origin.distance_to(path[0]) < 0.1:
		path.remove(0)
		if path.empty():
			return
	vel = global_transform.origin.direction_to(path[0]) * SPEED
	vel = move_and_slide(vel)


func set_target(target: Spatial):
	self.target = target
	set_physics_process(true)
	find_path_timer()


func _on_body_entered(body):
	print('%s devoured by %s' % [body.name, self.name])


func find_path_timer():
	path = path_finder.find_path(global_transform.origin, target.global_transform.origin)
	path.remove(0)
