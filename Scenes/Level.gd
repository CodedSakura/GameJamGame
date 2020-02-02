extends Node2D

func _ready():
    $Sprite.scale = $Camera2D.zoom
    get_parent().connect("reload_self", self, "_reload_self")
#    get_parent().connect("advance_level", self, "_advance_level")

func set_black():
    $Sprite.hide()

func set_color():
    $Sprite.show()
    
func _reload_self():
    get_tree().reload_current_scene()
    
#func _advance_level(name):
#    get_tree().change_scene(name)