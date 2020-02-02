extends Polygon2D

func _ready():
    $Area2D.connect("body_entered", get_parent().get_parent(), "_handle_death")
