@tool
extends Control
class_name ScreenControl

@export var screens: Array[Screen]
var current_screen: int = 0


func _ready() -> void:
    for screen in screens:
        setstate(screen, false)
    setstate(screens[current_screen], true)


func getallnodes(node: Node, state: bool):
    for N in node.get_children():
        if N.get_child_count() > 0:
            getallnodes(N, state)
        else:
            N.visible = state
            N.set_process(state)


func setstate(node: Node, state: bool):
    node.visible = state
    node.set_process(state)
    getallnodes(node, state)


func switch(screen: Screen):
    setstate(screens[current_screen], false)
    current_screen = screens.find(screen)
    setstate(screens[current_screen], true)
