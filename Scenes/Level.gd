extends Node2D

func _ready():
    $Sprite.scale = $Camera2D.zoom
    $Sprite.hide()

func set_black():
    $Sprite.hide()

func set_color():
    $Sprite.show()
