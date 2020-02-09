extends CanvasLayer

func _ready():
	$AnimationPlayer.connect("animation_started", self, "start_anim")
	$AnimationPlayer.connect("animation_finished", self, "end_anim")

func start_anim(val):
	get_tree().paused = true

func end_anim(val):
	get_tree().paused = false