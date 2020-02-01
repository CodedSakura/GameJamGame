extends Area2D

signal on_ladder
signal off_ladder

func _ready():
    self.connect("body_entered", self, "player_on_ladder")
    self.connect("body_exited", self, "player_off_ladder")

func player_on_ladder(player):
    self.connect("on_ladder", player, "enters_ladder")
    emit_signal("on_ladder")
    self.disconnect("on_ladder", player, "enters_ladder")
    
func player_off_ladder(player):
    self.connect("off_ladder", player, "leaves_ladder")
    emit_signal("off_ladder")
    self.disconnect("off_ladder", player, "leaves_ladder")