@tool
extends Control
class_name ScreenControl

@export var screens: Array[Screen]
var current_screen: int = 0


func _ready() -> void:
    for screen in screens:
        screen.visible = false
    screens[current_screen].visible = true

func switch(screen: Screen):
    screens[current_screen].visible = false
    current_screen = screens.find(screen)
    screen.visible = true
