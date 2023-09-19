extends Button

var timer
var bari3
# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(1.0)  # set the wait time to 5 seconds
	timer.set_one_shot(false)  # make it a one-shot timer
	timer.timeout.connect(_on_timer_timeout)
	bari3 = $"../TextureProgressBar4"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func alotaCDR():
	bari3.value = 0
	timer.start()
	
func _input(event):
	if Input.is_action_just_pressed("r"):
		set_pressed(true)
		
	else:
		set_pressed(false)
		
func _on_timer_timeout():
	
	bari3.value += 1
	if bari3.value == 6:
		timer.stop
