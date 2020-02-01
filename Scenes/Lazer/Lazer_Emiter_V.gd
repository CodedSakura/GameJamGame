extends StaticBody2D

export var emit_up = false
export var emit_down = true
export var speed = 100
export var max_count = 50

onready var BeamBase = preload("res://Scenes/Lazer/Lazer_Emiter_Base.gd").new()

var beams = []

func _ready():
    $Timer.connect("timeout", self, "add_beam")

func _physics_process(delta):
    if get_tree().paused:
        return
    for b in beams:
        b.update(delta)
        
func add_beam():
    if emit_up:
        beams.append(BeamBase.Beam.new(self, Vector2(0, -speed)))
    if emit_down:
        beams.append(BeamBase.Beam.new(self, Vector2(0, +speed)))
    while len(beams) > max_count:
        beams.pop_front().destroy()