enum Bounce {
    CW, CCW, NONE, DESTROY    
}

class Beam:
    var _beam
    var _vel
    var _parent
    var alive = true
    
    func _init(parent, vector):
        _vel = vector
        _parent = parent
        _beam = load("res://Scenes/Lazer/Lazer_Particle.tscn").instance()
        parent.add_child(_beam)
        _update_rotation()
        
    func update(delta):
        var collision = _beam.move_and_collide(_vel*delta)
        if collision:
            var pos = collision.collider.world_to_map(_beam.global_position + _vel.normalized() * 8)
            var bounce = _get_bounce(collision.collider, pos)
            var old_vel = _vel
            if bounce == Bounce.NONE:
                return
            elif bounce == Bounce.DESTROY:
                destroy()
                return
            elif bounce == Bounce.CW:
                _vel = _vel.rotated(PI/2).round()
            elif bounce == Bounce.CCW:
                _vel = _vel.rotated(-PI/2).round()
            else:
                return
            _update_rotation(old_vel)
            
    func _get_bounce(tm, posv): 
        var x = posv.x
        var y = posv.y
        var tile = tm.get_cell(x, y)
        if tile == -1:
            return Bounce.NONE
        if tile > 6 or tile < 3:
            return Bounce.DESTROY
        var v = Vector2(1 if tile % 2 == 0 else -1, -1 if tile <= 4 else 1)
        var norm = _vel.normalized()
#        print("[2] ", norm, " ", v)
        if norm.x == v.x or norm.y == v.y:
#            print("[1] ", v.angle() - norm.angle())
            if v.angle() - norm.angle() > 0:
                return Bounce.CCW
            return Bounce.CW
        else:
            return Bounce.DESTROY
        
    func _update_rotation(old_vel=null):
        if old_vel:
            _beam.position += _vel.normalized() * 10 + old_vel.normalized() * 10
        _beam.get_node("Sprite").rotation = _vel.angle()
        
    func destroy():
#        print("[3] ded: ", _beam.position)
        _parent.remove_child(_beam)
        alive = false