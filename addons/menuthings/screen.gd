@tool
extends Control

class_name Screen

signal loaded_screen
signal unloaded_screen

func screen_load() -> void:
    loaded_screen.emit()


func fswitch() -> void:
    unloaded_screen.emit()
    get_parent().switch(self)
