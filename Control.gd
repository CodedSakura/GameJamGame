extends Control

func _ready():
    $"/root/Transition/AnimationPlayer".play("fade_in")

func _on_TextureButton_pressed():
    $"/root/Transition/AnimationPlayer".play("fade_out")
    yield($"/root/Transition/AnimationPlayer", "animation_finished")
    get_tree().change_scene("res://Scenes/Menu.tscn")
