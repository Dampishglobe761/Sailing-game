@tool
extends Control
class_name Screen

func _ready() -> void:
    pass
    
func fswitch():
    get_parent().switch(self)
