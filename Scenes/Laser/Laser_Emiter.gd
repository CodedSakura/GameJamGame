tool
extends StaticBody2D

enum Direction {
    Up, Down, Left, Right
}

export (Direction) var direction = Direction.Left
export (float) var max_distance = 1000

const laser_line = preload("res://Scenes/Laser/LaserLine.tscn")

const direction_dict = {
    Direction.Up:    ["V", Vector2(1, +1), Vector2(0, -1)],
    Direction.Down:  ["V", Vector2(1, -1), Vector2(0, +1)],
    Direction.Left:  ["H", Vector2(-1, 1), Vector2(-1, 0)],
    Direction.Right: ["H", Vector2(+1, 1), Vector2(+1, 0)]
}

func _ready():
    process_direction()
    $RayCast2D.exclude_parent = true
    if not Engine.editor_hint:
        for p in get_tree().get_nodes_in_group("player"):
            $RayCast2D.add_exception(p)
        $"/root/Transition/AnimationPlayer".play("fade_in")
        yield($"/root/Transition/AnimationPlayer", "animation_finished")
        $Area2D.connect("body_entered", self, "area_collide")
        _calc_collisions()

func _process(delta):
    if Engine.editor_hint:
        process_direction()
        
func process_direction():
    var d = direction_dict[direction]
    $Sprite.texture = load("res://Assets/Tiles/Laser/LaserTurret"+d[0]+".png")
    $Sprite.scale = d[1]

func state_changed():
    if get_tree().paused:
        clear_lines()
    else:
        _calc_collisions()

func _calc_collisions():
    clear_lines()
    var v = direction_dict[direction][2]
    var nc = _get_next_collision(Vector2(0, 0), v)
    while nc:
        nc = _get_next_collision(nc[0], nc[1])

func clear_lines():
    for child in $LineNode.get_children():
        child.queue_free()
    for so in $Area2D.get_shape_owners():
        $Area2D.shape_owner_clear_shapes(so)
        $Area2D.remove_shape_owner(so)

func area_collide(what):
    if what is KinematicBody2D and what in get_tree().get_nodes_in_group("player"):
        get_tree().call_group("player", "player_death")
#    print(self.name, " > owie w/ ", what, " // ", what.name)

func add_line(v1, v2): # add to Area2D and LineNode
    var l = laser_line.instance()
    l.global_position = self.global_position
    l.add_point(v1)
    l.add_point(v2)
    $LineNode.add_child(l)
    
    var vdiff = v1 - v2
#    print(vdiff)
    var c = RectangleShape2D.new()
    if vdiff.x:
        c.extents = Vector2(vdiff.x / 2, 4)
    else:
        c.extents = Vector2(4, vdiff.y / 2)
    var cso = $Area2D.create_shape_owner(c)
    $Area2D.shape_owner_add_shape(cso, c)
    $Area2D.shape_owner_set_transform(cso, Transform2D(0, v1-vdiff/2))

func _get_next_collision(vec, dir):
    dir = dir.normalized()
    var rc = $RayCast2D
    rc.set_position(vec+dir*8)
    rc.set_cast_to(dir*max_distance)
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
            var v = Vector2(1 if tile % 2 == 1 else -1, -1 if tile <= 3 else 1)
            if dir.x == v.x or dir.y == v.y:
                add_line(vec, ppos)
                return [ppos, dir - v]
            else:
                add_line(vec, collv - self.global_position)
            return false
#        elif coll is KinematicBody2D:
#            get_tree().call_group("player", "player_death")
    else:
        add_line(vec, vec + dir*max_distance)
