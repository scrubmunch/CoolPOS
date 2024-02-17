extends CheckButton

@onready var pressed_highlight = $"../../../Control/Pressed"
@onready var hover_highlight = $"../../../Control/Hover"

func _on_pressed():
	if button_pressed:
		pressed_highlight.visible = true
	else:
		pressed_highlight.visible = false


func _on_mouse_entered():
	hover_highlight.visible = true


func _on_mouse_exited():
	hover_highlight.visible = false
