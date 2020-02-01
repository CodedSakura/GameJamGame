enum Bounce {
    CW, CCW, NONE, DESTROY    
}

class Beam:
    var _beam
    var _vel
    var _parent
    func _init(parent, vector):
        _vel = vector
        _parent = parent
        _beam = load("res://Scenes/Lazer/Lazer_Particle.tscn").instance()
        _update_rotation()
        parent.add_child(_beam)
    func update(delta):
        var collision = _beam.move_and_collide(_vel*delta)
        if collision:
            var pos = collision.collider.world_to_map(_beam.global_position + _vel.normalized() * 8)
            var bounce = _get_bounce(collision.collider, pos)
            if bounce == Bounce.NONE:
                return
            if bounce == Bounce.DESTROY:
                destroy()
            elif bounce == Bounce.CW:
                _vel = _vel.rotated(PI/2)
            elif bounce == Bounce.CCW:
                _vel = _vel.rotated(-PI/2)
    func _get_bounce(tm, posv): 
        var x = posv.x
        var y = posv.y
        var tile = tm.get_cell(x, y)
        if tile == -1:
            return Bounce.NONE
        # will need to be rewritten once 4 different sprites
        if tile != 2:
            return Bounce.DESTROY
        var flipped_x = tm.is_cell_x_flipped(x, y)
        var flipped_y = tm.is_cell_y_flipped(x, y)
        if not flipped_x and not flipped_y:
            pass
        elif flipped_x and not flipped_y:
            pass
        elif flipped_x and flipped_y:
            pass
        elif not flipped_x and flipped_y:
            pass
    func _update_rotation():
        _beam.get_node("Sprite").rotation = _vel.angle()
    func destroy():
        _parent.remove_child(_beam)