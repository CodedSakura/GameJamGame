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
    func update(delta):
        var collision = _beam.move_and_collide(_vec*delta)
        if collision:
            var pos = collision.collider.world_to_map(_beam.global_position + _vec.normalized() * 8)
            print(collision.collider.get_cellv(pos))
    func destroy():
        _parent.remove_child(_beam)