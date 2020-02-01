extends StaticBody2D

export var emit_left = false
export var emit_right = true
export var speed = 100
export var max_count = 50

onready var BeamBase = preload("res://Scenes/Lazer/Lazer_Emiter_Base.gd").new()

var beams = []

func _ready():
    $Timer.connect("timeout", self, "add_beam")
#    add_beam()
    
func _physics_process(delta):
    if get_tree().paused:
        return
    for b in beams:
        b.update(delta)
        if not b.alive:
            beams.erase(b)
        
func add_beam():
    if emit_left:
        beams.append(BeamBase.Beam.new(self, Vector2(-speed, 0)))
    if emit_right:
        beams.append(BeamBase.Beam.new(self, Vector2(+speed, 0)))
    while len(beams) > max_count:
        beams.pop_front().destroy()