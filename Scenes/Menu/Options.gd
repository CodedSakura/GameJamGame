extends Control

func _ready():
    $"/root/Transition/AnimationPlayer".play("fade_in")

func _on_BackButton_pressed():
    $"/root/Transition/AnimationPlayer".play("fade_out")
    yield($"/root/Transition/AnimationPlayer", "animation_finished")
    get_tree().change_scene("res://Scenes/Menu/Menu.tscn")


func _on_SFXToggle_pressed():
    pass # Replace with function body.


func _on_MusicToggle_pressed():
    pass # Replace with function body.


func _on_FullScreenToggle_pressed():
    pass # Replace with function body.


func _on_ControlsButton_pressed():
    $"/root/Transition/AnimationPlayer".play("fade_out")
    yield($"/root/Transition/AnimationPlayer", "animation_finished")
    get_tree().change_scene("res://Scenes/Menu/Controls.tscn")
