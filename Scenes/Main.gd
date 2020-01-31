extends Node2D

export var snap_px = 16

var is_picked = false
var offset
var picked_piece
var start_pos
var overlaps = false

func _process(delta):
	if Input.is_action_just_pressed("mouse_left"):
		pick_piece()
	if Input.is_action_just_released("mouse_left") && is_picked:
		is_picked = false
		picked_piece.get_node("Area2D").disconnect("area_entered", self, "_overlaps_true")
		picked_piece.get_node("Area2D").disconnect("area_exited", self, "_overlaps_false")
		if overlaps:
			picked_piece.position = start_pos
		overlaps = false

	if is_picked:
		var move = get_viewport().get_mouse_position() - start_pos + offset
		picked_piece.position = snap(move)

func snap(mv):
	mv.x = round(mv.x/snap_px)*snap_px
	mv.y = round(mv.y/snap_px)*snap_px
	mv.x = start_pos.x + mv.x
	mv.y = start_pos.y + mv.y
	return mv

func pick_piece():
	var mouse_pos = get_viewport().get_mouse_position()
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_point(mouse_pos, 10, [], 2, false, true) # DETECTO TIKAI 2. LAYER
	if result.size():
		picked_piece = result[0].collider.get_parent()
		offset = picked_piece.position - mouse_pos
		is_picked = true
		start_pos = picked_piece.position
		picked_piece.get_node("Area2D").connect("area_entered", self, "_overlaps_true")
		picked_piece.get_node("Area2D").connect("area_exited", self, "_overlaps_false")
		
func _overlaps_true(area):
	overlaps = true
	
func _overlaps_false(area):
	overlaps = false