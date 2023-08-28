extends Button

@onready var bar = $TextureProgressBar1

var timer
var health
var cd = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	timer = Timer.new()  # create a new Timer
	add_child(timer)  # add it as a child
	timer.set_wait_time(1.0)  # set the wait time to 5 seconds
	timer.set_one_shot(true)  # make it a one-shot timer
	timer.timeout.connect(_on_timer_timeout)
	#bar.update_bar(100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if timer.is_stopped()å
	pass

func _input(event):
	if Input.is_action_just_pressed("q"):
		set_pressed(true)
#		var ddd = "ss oo"
#		var uus = ddd.split()
#		print(uus)
		timer.start()
	else:
		set_pressed(false)



func _on_timer_timeout():
	var bari = $"../TextureProgressBar2"
	bari.value -= 1
