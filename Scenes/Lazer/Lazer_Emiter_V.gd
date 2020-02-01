extends StaticBody2D

export var emit_up = true
export var emit_down = false
export var speed = 192
export var max_count = 50

onready var BeamBase = preload("res://Scenes/Lazer/Lazer_Emiter_Base.gd").new()

var beams = []

func _ready():
    $Timer.connect("timeout", self, "add_beam")

func _physics_process(delta):
    if get_tree().paused:
        while len(beams) > 0:
            beams.pop_front().destroy()
        return
    for b in beams:
        b.update()
        if not b.alive:
            beams.erase(b)
        
func add_beam():
    if get_tree().paused:
        return
    if emit_up:
        beams.append(BeamBase.Beam.new(self, Vector2(0, -speed)))
    if emit_down:
        beams.append(BeamBase.Beam.new(self, Vector2(0, +speed)))
    while len(beams) > max_count:
        beams.pop_front().destroy()