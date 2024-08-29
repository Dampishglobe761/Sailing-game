@tool extends EditorPlugin


func _enter_tree() -> void:
    add_custom_type("ScreenControl", "Control", 
        preload("res://addons/menuthings/screencontroller.gd"), 
        preload("res://icon.svg"))
    add_custom_type("Screen", "Control", 
        preload("res://addons/menuthings/screen.gd"), 
        preload("res://icon.svg"))


func _exit_tree() -> void:
    remove_custom_type("ScreenControl")
    remove_custom_type("Screen")
