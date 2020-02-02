extends KinematicBody2D
 
export var move_speed = 500

export var gravity = 8
export var fallMultiplier = 2
export var lowJumpMultiplier = 10 
export var jumpVelocity = 400
 
onready var anim_player = $AnimatedSprite

signal player_death
 
var velocity = Vector2(0, 0)
var facing_right = true

var on_ladder = false

# <placeholder>
func _ready():
    connect("player_death", self, "_player_death")

func _player_death():
    print("ded") 
# </placeholder>

func _physics_process(delta):
    
    move_and_slide(velocity, Vector2(0, -1), true)
    var grounded = is_on_floor()
    
    # collision with specific tiles
    for i in get_slide_count():
        var coll = get_slide_collision(i).collider
        if coll.name.find("Lazer_Beam") >= 0:
            emit_signal("player_death")
        elif coll is TileMap:
            var gpos = self.global_position - coll.global_position
            for j in [Vector2(0, 17), Vector2(0, -15), Vector2(9, 9), Vector2(9, -9), Vector2(-9, 9), Vector2(-9, -9)]:
                var pos = coll.world_to_map(gpos + j)
                if coll.get_cellv(pos) == 7:
                    emit_signal("player_death")
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
        if Input.is_action_pressed("ui_down"): #TODO parsaukt uz down
            velocity.y += 1
        velocity = velocity.normalized() * move_speed
    
    if (facing_right && move_dir < 0) || (!facing_right and move_dir > 0):
        flip()
   	
    if grounded:
        if move_dir == 0:
            play_anim("walk") #idle
        else:
            play_anim("walk") #walk
    else:
        play_anim("walk") #jump
 
func enters_ladder():
    on_ladder = true
    
func leaves_ladder():
    on_ladder = false

func flip():
    facing_right = !facing_right
    anim_player.flip_h = !anim_player.flip_h
 
func play_anim(anim_name):
    if anim_player.is_playing() and anim_player.animation == anim_name:
        return
    anim_player.play(anim_name)

func set_black():
    modulate = Color(1, 1, 1)

func set_color():
    modulate = Color(0, 0, 0)