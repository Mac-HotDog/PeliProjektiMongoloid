extends Timer

# This variable is exposed to the editor
@export var custom_duration: float = 5.0

func _ready():
	self.wait_time = custom_duration
