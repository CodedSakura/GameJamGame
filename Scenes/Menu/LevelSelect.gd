extends Control

var LevelDict = {}

func _ready():
    $"/root/Transition/AnimationPlayer".play("fade_in")
    yield($"/root/Transition/AnimationPlayer", "animation_finished")
    LevelDict = {
        $GridContainer/L1Button: "1",
        $GridContainer/L2Button: "2",
        $GridContainer/L3Button: "3",
        $GridContainer/L4Button: "4",
        $GridContainer/L5Button: "5",
        $GridContainer/L6Button: "6",
        $GridContainer/L7Button: "7",
        $GridContainer/L8Button: "8",
        $GridContainer/L9Button: "9",
        $GridContainer/L10Button: "10",
        $GridContainer/B1Button: "B1",
        $GridContainer/B2Button: "B2",
    }
    for c in LevelDict.keys():
        c.connect("pressed", self, "_on_LevelButton_pressed", [c])


func _on_BackButton_pressed():
    $"/root/Transition/AnimationPlayer".play("fade_out")
    yield($"/root/Transition/AnimationPlayer", "animation_finished")
    get_tree().change_scene("res://Scenes/Menu/Menu.tscn")

func _on_LevelButton_pressed(btn):
    if btn in LevelDict:
        globals.load_level = LevelDict[btn]
        $"/root/Transition/AnimationPlayer".play("fade_out")
        yield($"/root/Transition/AnimationPlayer", "animation_finished")
        get_tree().change_scene("res://Scenes/Main.tscn")
