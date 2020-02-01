extends StaticBody2D

export var emit_left = false
export var emit_right = true
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
    if emit_left:
        beams.append(BeamBase.Beam.new(self, Vector2(-speed, 0)))
    if emit_right:
        beams.append(BeamBase.Beam.new(self, Vector2(+speed, 0)))
    while len(beams) > max_count:
        beams.pop_front().destroy()