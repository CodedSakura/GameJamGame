extends KinematicBody2D
 
export var move_speed = 500

export var gravity = 8
export var fallMultiplier = 2
export var lowJumpMultiplier = 10 
export var jumpVelocity = 400
 
onready var anim_player = $AnimatedSprite

signal player_death
signal player_victory
 
var velocity = Vector2(0, 0)
var facing_right = true

var on_ladder = false
    
func player_death():
    emit_signal("player_death")
func coll(v):
    print(v)

func _physics_process(delta):
    
    move_and_slide(velocity, Vector2(0, -1), true)
    var grounded = is_on_floor()
    
    for i in get_slide_count():
        var coll = get_slide_collision(i).collider
        if coll is TileMap:
            var gpos = self.global_position - coll.global_position
#            for j in [Vector2(0, 17), Vector2(0, -15), Vector2(9, 9), Vector2(9, -9), Vector2(-9, 9), Vector2(-9, -9)]:
            for j in [
                    Vector2(8, 14), Vector2(-8, 14), Vector2(8, 0), Vector2(-8, 0), Vector2(8, -14), Vector2(-8, -14),
                    Vector2(7, 15), Vector2(-7, 15), Vector2(7, -15), Vector2(-7, -15)
                ]:
                var cell = coll.get_cellv(coll.world_to_map(gpos + j))
                if cell == 7:
                    emit_signal("player_death")
                    break
                elif cell == 6:
                    emit_signal("player_victory")
                    break
    
    var move_dir = 0
        
    if Input.is_action_pressed("move_right"):
        move_dir += 1
    if Input.is_action_pressed("move_left"):
        move_dir -= 1
       
    
    if !on_ladder: # Physics w/o ladders
    
        velocity.x = move_dir * move_speed
        
        velocity.y += gravity 
    
        if grounded and velocity.y >= 1:
            velocity.y = 1
    
        if velocity.y > 0: 
            velocity += Vector2.UP * (-9.81) * (fallMultiplier)
        elif velocity.y < 0 && Input.is_action_just_released("jump"):
            velocity += Vector2.UP * (-9.81) * (lowJumpMultiplier)
            
        if grounded && Input.is_action_just_pressed("jump"): 
            velocity += Vector2.UP * jumpVelocity
    else: # Physics w/ ladders
    
        velocity.x = move_dir
    
        velocity.y = 0
        if Input.is_action_pressed("jump"):
            velocity.y -= 1
        if Input.is_action_pressed("down"):
            velocity.y += 1
        velocity = velocity.normalized() * move_speed
    
    if (facing_right && move_dir < 0) || (!facing_right and move_dir > 0):
        flip()

    if on_ladder:
        play_anim("climb")
    else:
        play_anim("walk")
 
func enters_ladder():
    on_ladder = true
    
func leaves_ladder():
    on_ladder = false

func flip():
    facing_right = !facing_right
#    anim_player.flip_h = !anim_player.flip_h
    self.scale.x *= -1
 
func play_anim(anim_name):
    if anim_player.is_playing() and anim_player.animation == anim_name:
        return
    anim_player.play(anim_name)

func set_black():
    modulate = Color(1, 1, 1)

func set_color():
    modulate = Color(0, 0, 0)
