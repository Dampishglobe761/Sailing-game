@tool
extends Control

class_name Screen

func screen_load() -> void:
    pass


func fswitch() -> void:
    get_parent().switch(self)
