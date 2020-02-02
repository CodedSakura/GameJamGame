extends Node2D

export var snap_px = 16

var is_picked = false
var offset
var picked_piece
var start_pos
var overlaps = false

var is_player_picked = false
var overlaps_player = null
var overlaps_player_really = null
var player_offset

func _ready():
    $Level/Player.connect("player_death", self, "_handle_death")
    $Level/Player.connect("player_victory", self, "_handle_victory")

func _handle_death(pos):
    $Level/Player.global_position = pos
    # temporary
#    get_node("Level")
    get_tree().reload_current_scene()

func _handle_victory():
    print("u winned")

func _process(delta):
	handle_pausing()
	handle_drag()

func handle_pausing():
	if Input.is_action_just_pressed("pause") && !is_picked:
		get_tree().paused = !get_tree().paused
		Physics2DServer.set_active(true)

func handle_drag():
	if Input.is_action_just_pressed("mouse_left") && get_tree().paused:
		var mouse = get_viewport().get_mouse_position()
		pick_piece(mouse)
		if is_picked && picked_piece == overlaps_player_really:
			pick_player(mouse)
	if Input.is_action_just_released("mouse_left") && is_picked:
		is_picked = false
		picked_piece.get_node("Area2D").disconnect("area_entered", self, "_overlaps_true")
		picked_piece.get_node("Area2D").disconnect("area_exited", self, "_overlaps_false")
		picked_piece.get_node("Area2D").disconnect("body_entered", self, "_overlaps_player_true")
		picked_piece.get_node("Area2D").disconnect("body_exited", self, "_overlaps_player_false")
		if overlaps:
			picked_piece.position = start_pos
			if is_player_picked:
				overlaps_player_really = picked_piece
				$Player.position = start_pos + player_offset
			elif picked_piece == overlaps_player:
				overlaps_player = overlaps_player_really
		else:
			overlaps_player_really = overlaps_player
		
		is_player_picked = false
		picked_piece = null
		overlaps = false

	if is_picked:
		var move = get_viewport().get_mouse_position() - start_pos + offset
		picked_piece.position = snap(move)
		if is_player_picked && picked_piece == overlaps_player_really:
			$Player.position = picked_piece.position + player_offset

func snap(mv):
	mv.x = round(mv.x/snap_px)*snap_px
	mv.y = round(mv.y/snap_px)*snap_px
	mv.x = start_pos.x + mv.x
	mv.y = start_pos.y + mv.y
	return mv

func pick_player(mouse_pos):
	player_offset = $Player.position - start_pos
	is_player_picked = true

func pick_piece(mouse_pos):
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_point(mouse_pos, 10, [], 2, false, true) # DETECTO TIKAI 2. LAYER
	if result.size():
		picked_piece = result[0].collider.get_parent()
		offset = picked_piece.position - mouse_pos
		is_picked = true
		start_pos = picked_piece.position
		picked_piece.get_node("Area2D").connect("area_entered", self, "_overlaps_true")
		picked_piece.get_node("Area2D").connect("area_exited", self, "_overlaps_false")
		picked_piece.get_node("Area2D").connect("body_entered", self, "_overlaps_player_true")
		picked_piece.get_node("Area2D").connect("body_exited", self, "_overlaps_player_false")
		var player_arr = picked_piece.get_node("Area2D").get_overlapping_bodies()
		if player_arr.size() && player_arr[0] == $Player:
			overlaps_player_really = picked_piece
		
func _overlaps_true(area):
	overlaps = true
	
func _overlaps_false(area):
	overlaps = false

func _overlaps_player_true(area):
	overlaps_player = picked_piece

func _overlaps_player_false(area):
	overlaps_player = null