extends StaticBody3D



func _ready():
	# Create a new AnimationPlayer
	var anim_player = AnimationPlayer.new()

	# Add the AnimationPlayer to the current node
	self.add_child(anim_player)

	# Create a new Animation
	var anim = Animation.new()

	# Set up the animation length to 2 seconds
	anim.length = 2.0

	# Add a track for the rotation_degrees.y property
	anim.add_track(Animation.TYPE_VALUE)

	# Set the track path to point to the rotation_degrees.y property
	anim.track_set_path(0, "rotation_degrees.y")

	# Insert keyframes at 0 and 2 seconds
	anim.track_insert_key(0, 0, 0)
	anim.track_insert_key(0, 2, 360)

	# Add the animation to the AnimationPlayer
	var anim_name = "rotation"
	
	
	
	# Play the animation
	#anim_player.play("anim")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
