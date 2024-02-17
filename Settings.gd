extends Control

@onready var crt = %CRT
@onready var crt_switch = %VHSswitch

func _input(event):
	if event.is_action_pressed("Settings"):
		visible = !visible

func _on_vh_sswitch_pressed():
	crt.visible = crt_switch.button_pressed
