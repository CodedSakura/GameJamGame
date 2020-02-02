extends StaticBody2D

enum Directon {
    Up, Down, Left, Right
}

export (Directon) var dir = Directon.Left

var needs_update = true

func _ready():
    $Line2D.add_point(Vector2(0, 0))

func _physics_process(delta):
#    if !needs_update:
#        return
    var ss = get_world_2d().direct_space_state
    var res = ss.intersect_ray(self.global_position, Vector2(-1000, 0), [self])
    if res:
        var coll = res.collider
        print("ye: ", res, "; ", coll.world_to_map(res.position - coll.global_position))
        $Line2D.add_point(res.position - $Line2D.global_position)
        needs_update = false
