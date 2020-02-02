extends Node2D

export var snap_px = 16

var player_camera
var scene_camera

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

func _ready():
    $Level/Player.connect("player_death", self, "_handle_death")
    $Level/Player.connect("player_victory", self, "_handle_victory")
    curr_level = $Level
    reset_camera()

func _handle_death(ignored):
	if !get_tree().paused:
	    call_deferred("_load_level", $Level.filename.trim_prefix("res://Scenes/Levels/").trim_suffix("/Level.tscn"))

func _load_level(n):
    remove_child(curr_level)
    var res = load("res://Scenes/Levels/" + str(n) + "/Level.tscn")
    curr_level = res.instance()
    add_child(curr_level)
    _reset_vars()
    curr_level.get_node("Player").connect("player_death", self, "_handle_death")
    curr_level.get_node("Player").connect("player_victory", self, "_handle_victory")
    reset_camera()

func _handle_victory():
    var n = int($Level.filename.trim_prefix("res://Scenes/Levels/").trim_suffix("/Level.tscn"))
    if n > 0:
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
	handle_pausing()
	handle_drag()

func handle_pausing():
	if Input.is_action_just_pressed("pause") && !is_picked:
		get_tree().paused = !get_tree().paused
		Physics2DServer.set_active(true)
		if get_tree().paused:
            scene_camera.make_current()
            set_tint(false)
		else:
            player_camera.make_current()
            set_tint(true)

func handle_drag():
	if Input.is_action_just_pressed("mouse_left") && get_tree().paused:
		var mouse = get_global_mouse_position()
		pick_piece(mouse)
		if is_picked && picked_piece == overlaps_player_really:
			pick_player(mouse)
	if Input.is_action_just_released("mouse_left") && is_picked:
		is_picked = false
		picked_piece.get_node("Modulate/Area2D").disconnect("area_entered", self, "_overlaps_true")
		picked_piece.get_node("Modulate/Area2D").disconnect("area_exited", self, "_overlaps_false")
		picked_piece.get_node("Modulate/Area2D").disconnect("body_entered", self, "_overlaps_player_true")
		picked_piece.get_node("Modulate/Area2D").disconnect("body_exited", self, "_overlaps_player_false")
		if overlaps:
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

	if is_picked:
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