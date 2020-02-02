extends StaticBody2D

enum Directon {
    Up, Down, Left, Right
}

export (Directon) var dir = Directon.Left

var needs_update = true

func _physics_process(delta):
    $Line2D.clear_points()
    $Line2D.add_point(Vector2(0,0))
    
    var nc = _get_next_colision(Vector2(0, 0), Vector2(-1, 0))
    print(nc)
    while nc:
        nc = _get_next_colision(nc[0], nc[1])

func _get_next_colision(vec, dir):
    $RayCast2D.exclude_parent = true
    $RayCast2D.position = vec + self.global_position
    $RayCast2D.cast_to = dir.normalized()*1000 + self.global_position
    $RayCast2D.force_raycast_update()
    var res = $RayCast2D.get_collider()
    if res:
        var coll = res.collider
        $Line2D.add_point(res.position - $Line2D.global_position)
        if coll is TileMap:
            var pos = coll.world_to_map(res.position - coll.global_position)
            var tile = coll.get_cellv(pos)
            if tile == -1:
                return null
            if tile > 5 or tile < 2:
                return false
            var v = Vector2(1 if tile % 2 == 1 else -1, -1 if tile <= 3 else 1)
            var norm = dir.normalized()
            if norm.x == v.x or norm.y == v.y:
                return [res.position - self.global_position, norm - v]