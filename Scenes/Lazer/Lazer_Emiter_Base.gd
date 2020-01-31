class Beam:
    var _beam
    var _vec
    var _parent
    func _init(parent, vector):
        _vec = vector
        _parent = parent
        _beam = load("res://Scenes/Lazer/Lazer_Particle.tscn").instance()
        _beam.get_node("Sprite").rotation = _vec.angle()
        parent.add_child(_beam)
    func update():
        _beam.move_and_slide(_vec)
    func destroy():
        _parent.remove_child(_beam)