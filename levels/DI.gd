extends Spatial

onready var monster = $GridMap/Monster
onready var player = $GridMap/Player

var collected_orb_count = 0
var total_orb_count = 0


func _ready():
	monster.set_target(player)
	
	var orbs = get_tree().get_nodes_in_group('orbs')
	total_orb_count = orbs.size()
	player.connect('orb_collected', self, 'on_orb_collected')


func on_orb_collected():
	collected_orb_count += 1
	if collected_orb_count >= total_orb_count:
		print('You win!')


func _unhandled_key_input(event):
	if OS.is_debug_build() and event.scancode == KEY_CONTROL:
		get_tree().quit()
