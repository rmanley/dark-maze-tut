extends SpotLight


var timer: Timer = null
const TIMER_INTERVAL_MIN = 0.05
const TIMER_INTERVAL_MAX = 0.1

func _ready():
	randomize()
	timer = Timer.new()
	timer.wait_time = rand_range(TIMER_INTERVAL_MIN, TIMER_INTERVAL_MAX)
	timer.connect("timeout", self, 'on_timer_timeout')
	add_child(timer)
	timer.start()


func on_timer_timeout():
	timer.wait_time = rand_range(TIMER_INTERVAL_MIN, TIMER_INTERVAL_MAX)
	light_energy = rand_range(0.0, 1.0)
