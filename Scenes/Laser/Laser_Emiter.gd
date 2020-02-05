tool
extends StaticBody2D

enum Direction {
    Up, Down, Left, Right
}

export (Direction) var direction = Direction.Left

const laser_line = preload("res://Scenes/Laser/LaserLine.tscn")

func _ready():
    process_direction()
    if not Engine.editor_hint:
        $"/root/Transition/AnimationPlayer".play("fade_in")
        yield($"/root/Transition/AnimationPlayer", "animation_finished")

        $RayCast2D.exclude_parent = true
        _calc_collisions()

func _process(delta):
    if Engine.editor_hint:
        process_direction()
        
func process_direction():
    if direction == Direction.Up:
        $Sprite.texture = load("res://Assets/Tiles/Laser/LaserTurretV.png")
        $Sprite.scale = Vector2(1, +1)
    elif direction == Direction.Down:
        $Sprite.texture = load("res://Assets/Tiles/Laser/LaserTurretV.png")
        $Sprite.scale = Vector2(1, -1)
    elif direction == Direction.Left:
        $Sprite.texture = load("res://Assets/Tiles/Laser/LaserTurretH.png")
        $Sprite.scale = Vector2(-1, 1)
    elif direction == Direction.Right:
        $Sprite.texture = load("res://Assets/Tiles/Laser/LaserTurretH.png")
        $Sprite.scale = Vector2(+1, 1)

func state_changed():
    if get_tree().paused:
        for child in $LineNode.get_children():
            child.queue_free()
    else:
        _calc_collisions()

func _calc_collisions():
    for child in $LineNode.get_children():
        child.queue_free()
    
    var v
    if direction == Direction.Up:
        v = Vector2(0, -1)
    elif direction == Direction.Down:
        v = Vector2(0, +1)
    elif direction == Direction.Left:
        v = Vector2(-1, 0)
    elif direction == Direction.Right:
        v = Vector2(+1, 0)
    
    print("> ", "init calc")
    var nc = _get_next_collision(Vector2(0, 0), v)
    while nc:
        nc = _get_next_collision(nc[0], nc[1])

func add_line(v1, v2): # add to Area2D and LineNode
    var l = laser_line.instance()
    l.global_position = self.global_position
    l.add_point(v1)
    l.add_point(v2)
    $LineNode.add_child(l)

func _get_next_collision(vec, dir):
    dir = dir.normalized()
    var rc = $RayCast2D
    rc.set_position(vec+dir*8)
    rc.set_cast_to(dir*1000)
    rc.force_raycast_update()
    if rc.is_colliding():
        var coll = rc.get_collider()
        var collv = rc.get_collision_point()
        if coll is TileMap:
            var pos = coll.world_to_map(collv - coll.global_position)
            var tile = coll.get_cellv(pos)
            var ppos = coll.map_to_world(pos) + Vector2(8, 8) + coll.global_position - self.global_position
            if tile > 5 or tile < 2:
                add_line(vec, ppos + dir*8)
                return false
            print("2.5> ", vec, ppos, pos, collv)
            var v = Vector2(1 if tile % 2 == 1 else -1, -1 if tile <= 3 else 1)
            if dir.x == v.x or dir.y == v.y:
                add_line(vec, ppos)
                return [ppos, dir - v]
            else:
                add_line(vec, collv - self.global_position)
            return false
        elif coll is KinematicBody2D:
            get_tree().call_group("player", "player_death")
    else:
        add_line(vec, vec + dir*1000)
