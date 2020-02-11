extends Node2D

export var snap_px = 16

export var fade_duration = 1.00
export var fade_type = 1 # TRANS_SINE

var player_camera
var scene_camera

var won = null

var is_picked = false
var offset
var picked_piece
var start_pos
var overlaps = 0

var is_player_picked = false
var overlaps_player = null
var overlaps_player_really = null
var player_offset

var curr_level

signal state_changed

var entering_cheat = false
var entered_cheat = ""

var level_pause = false
var global_pause = false

func _ready():
    _load_level(globals.load_level, true)
#    $"/root/Transition/AnimationPlayer".play("fade_in")
#    yield($"/root/Transition/AnimationPlayer", "animation_finished")
    $Level/Player.connect("player_death", self, "_handle_death")
    $Level/Player.connect("player_victory", self, "_handle_victory")
    curr_level = $Level
    reset_camera()
    
    current_music = $Music1
    current_music_id = 1
    current_music.volume_db = 0

func _handle_death(ignored=null):
    won = false
    if !get_tree().paused:
        call_deferred("_load_level", $Level.filename.trim_prefix("res://Scenes/Levels/").trim_suffix("/Level.tscn"))

func _load_level(n, skip_fadeout=false):
    var res = load("res://Scenes/Levels/" + str(n) + "/Level.tscn")
    if not res:
        return
    if not skip_fadeout:
        $"/root/Transition/AnimationPlayer".play("fade_out_alt" if !won else "fade_out")
        yield($"/root/Transition/AnimationPlayer", "animation_finished")
        curr_level.get_node("Player").disconnect("player_death", self, "_handle_death")
        curr_level.get_node("Player").disconnect("player_victory", self, "_handle_victory")
        curr_level.free()
    curr_level = res.instance()
    add_child(curr_level)
    _reset_vars()
    curr_level.get_node("Player").connect("player_death", self, "_handle_death")
    curr_level.get_node("Player").connect("player_victory", self, "_handle_victory")
    reset_camera()
    $"/root/Transition/AnimationPlayer".play("fade_in")
    yield($"/root/Transition/AnimationPlayer", "animation_finished")

func _handle_victory():
    won = true
    var n = int($Level.filename.trim_prefix("res://Scenes/Levels/").trim_suffix("/Level.tscn"))
    if n == 9:
        $"/root/Transition/AnimationPlayer".play("fade_out")
        yield($"/root/Transition/AnimationPlayer", "animation_finished")
        get_tree().change_scene("res://Scenes/Menu/Credits.tscn")
        globals.load_level = "1"
    elif n > 0:
        call_deferred("_load_level", n+1)

func _reset_vars():
    is_picked = false
    offset = null
    picked_piece = null
    start_pos = null
    overlaps = 0
    
    is_player_picked = false
    overlaps_player = null
    overlaps_player_really = null
    player_offset = null

func _process(delta):
    if not global_pause:
        handle_pausing()
        handle_drag()
        handle_cheats()
        handle_reset()
        handle_music()
    handle_pause_menu()

var was_in = null
func handle_music():
    if !get_tree().paused:
        var space_state = get_world_2d().direct_space_state
        var result = space_state.intersect_point($Level/Player.position, 10, [], 2, false, true)
        if result.size() && result[0].collider != was_in:
            switch_music()
            was_in = result[0].collider

var current_music
var current_music_id
func switch_music():
    var rng = RandomNumberGenerator.new()
    var rand_int = rng.randi_range(1, 4)
    while rand_int == current_music_id:
        rng.randomize()
        rand_int = rng.randi_range(1, 4)
    current_music_id = rand_int
    $Tween.interpolate_property(current_music, "volume_db", 0, -80, fade_duration, fade_type, Tween.EASE_IN_OUT)
    $Tween.connect("tween_completed", self, "stop_music", [current_music])
    current_music = get_node("Music" + str(current_music_id))
    current_music.play($Bass.get_playback_position())
    $Tween.interpolate_property(current_music, "volume_db", -80, 0, fade_duration, fade_type, Tween.EASE_IN_OUT)
    $Tween.start()

func stop_music(a,b,c):
    a.stop()
    $Tween.disconnect("tween_completed", self, "stop_music")

func handle_pausing():
    if not entering_cheat and Input.is_action_just_pressed("pause") && !is_picked && !$"/root/Transition/AnimationPlayer".is_playing():
        level_pause = !level_pause
        get_tree().paused = level_pause
        Physics2DServer.set_active(true)
        if level_pause:
            scene_camera.make_current()
            set_tint(false)
        else:
            player_camera.make_current()
            set_tint(true)
        get_tree().call_group("lasers", "state_changed")

func handle_drag():
    if Input.is_action_just_pressed("mouse_left") && get_tree().paused:
        var mouse = get_global_mouse_position()
        pick_piece(mouse)
        if is_picked && picked_piece == overlaps_player_really:
            pick_player(mouse)
    elif Input.is_action_just_released("mouse_left") && is_picked:
        is_picked = false
        picked_piece.get_node("Modulate/Area2D").disconnect("area_entered", self, "_overlaps_true")
        picked_piece.get_node("Modulate/Area2D").disconnect("area_exited", self, "_overlaps_false")
        picked_piece.get_node("Modulate/Area2D").disconnect("body_entered", self, "_overlaps_player_true")
        picked_piece.get_node("Modulate/Area2D").disconnect("body_exited", self, "_overlaps_player_false")
        if overlaps || curr_level.get_node("Player").test_move(curr_level.get_node("Player").transform.translated(Vector2(0, -1)), Vector2(0, 0)):
            picked_piece.position = start_pos
            if is_player_picked:
                overlaps_player_really = picked_piece
                curr_level.get_node("Player").position = start_pos + player_offset
            elif picked_piece == overlaps_player:
                overlaps_player = overlaps_player_really
        else:
            overlaps_player_really = overlaps_player
        
        is_player_picked = false
        picked_piece = null
        overlaps = 0
    elif is_picked:
        var move = get_global_mouse_position() - start_pos + offset
        picked_piece.position = snap(move)
        if is_player_picked && picked_piece == overlaps_player_really:
            curr_level.get_node("Player").position = picked_piece.position + player_offset

func snap(mv):
    mv.x = round(mv.x/snap_px)*snap_px
    mv.y = round(mv.y/snap_px)*snap_px
    mv.x = start_pos.x + mv.x
    mv.y = start_pos.y + mv.y
    return mv

func pick_player(mouse_pos):
    player_offset = curr_level.get_node("Player").position - start_pos
    is_player_picked = true

func pick_piece(mouse_pos):
    var space_state = get_world_2d().direct_space_state
    var result = space_state.intersect_point(mouse_pos, 10, [], 2, false, true) # DETECTO TIKAI 2. LAYER
    if result.size():
        picked_piece = result[0].collider.get_parent().get_parent()
        offset = picked_piece.position - mouse_pos
        is_picked = true
        start_pos = picked_piece.position
        picked_piece.get_node("Modulate/Area2D").connect("area_entered", self, "_overlaps_true")
        picked_piece.get_node("Modulate/Area2D").connect("area_exited", self, "_overlaps_false")
        picked_piece.get_node("Modulate/Area2D").connect("body_entered", self, "_overlaps_player_true")
        picked_piece.get_node("Modulate/Area2D").connect("body_exited", self, "_overlaps_player_false")
        var player_arr = picked_piece.get_node("Modulate/Area2D").get_overlapping_bodies()
        if player_arr.size() && player_arr[0] == $Level/Player:
            overlaps_player_really = picked_piece
        else:
            overlaps_player_really = null

func set_tint(set):
    if set:
        get_tree().call_group("modulate", "set_black")
    else:
        get_tree().call_group("modulate", "set_color")

func reset_camera():
    player_camera = curr_level.get_node("Player").get_node("Camera2D")
    scene_camera = curr_level.get_node("Camera2D")
    player_camera.make_current()

func _overlaps_true(area):
    overlaps += 1   
func _overlaps_false(area):
    overlaps -= 1
func _overlaps_player_true(area):
    overlaps_player = picked_piece
func _overlaps_player_false(area):
    overlaps_player = null

func handle_reset():
    if Input.is_action_just_pressed("reset"):
        _handle_death()

func handle_cheats():
    if Input.is_action_just_pressed("cheat_activate"):
        entering_cheat = true
        print("enter cheat...")
    if entering_cheat and Input.is_action_just_pressed("cheat_apply"):
        print("applying cheat ", entered_cheat)
        if entered_cheat.begins_with("level "):
            print("changing level")
            _load_level(entered_cheat.trim_prefix("level "))
        else: print("unknown cheat")
        entered_cheat = ""
        entering_cheat = false
    if entering_cheat and Input.is_action_just_pressed("cheat_cancel"):
        print("cancelling cheat")
        entered_cheat = ""
        entering_cheat = false

func _input(event):
    if entering_cheat and event is InputEventKey and event.pressed:
        entered_cheat += char(event.unicode)
        print(entered_cheat)

func _toggle_pause():
    global_pause = !global_pause
    $PauseMenu/Root.visible = global_pause
    get_tree().paused = global_pause or level_pause

func handle_pause_menu():
    if Input.is_action_just_pressed("pause_menu"):
        _toggle_pause()

func _on_PauseMenu_RestartButton_pressed():
    _toggle_pause()
    call_deferred("_load_level", $Level.filename.trim_prefix("res://Scenes/Levels/").trim_suffix("/Level.tscn"))

func _on_PauseMenu_ResumeButton_pressed():
    _toggle_pause()
    
func _on_PauseMenu_ExitButton_pressed():
    _toggle_pause()
    $"/root/Transition/AnimationPlayer".play("fade_out")
    yield($"/root/Transition/AnimationPlayer", "animation_finished")
    get_tree().change_scene("res://Scenes/Menu/Menu.tscn")
