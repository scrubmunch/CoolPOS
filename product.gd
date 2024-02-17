class_name Product extends Control

var title : String
var price : float
var group_id : int
var color : Color

@onready var button : Button = $Button
@onready var label : Label = $Label

signal pressed(_title, _price)

func set_values(_title : String, _price : float, _group_id : int, _color : String):
	title = _title
	price = _price
	group_id = _group_id
	color = Color(_color)

func _ready():
	label.set_text(title)
	
	if (color.get_luminance() < 0.85):
		label.add_theme_color_override("font_color", Color(1, 1, 1))
	else:
		label.add_theme_color_override("font_color", Color(0.004, 0.059, 0.027))

	var stylebox_normal = button.get_theme_stylebox("normal").duplicate()
	stylebox_normal.bg_color = color
	button.add_theme_stylebox_override("normal", stylebox_normal)
	
	var stylebox_hover = button.get_theme_stylebox("hover").duplicate()
	stylebox_hover.bg_color = color.lightened(0.2)
	button.add_theme_stylebox_override("hover", stylebox_hover)
	
	var stylebox_pressed = button.get_theme_stylebox("pressed").duplicate()
	stylebox_pressed.bg_color = color.darkened(0.1)
	button.add_theme_stylebox_override("pressed", stylebox_pressed)


func _on_button_pressed():
	pressed.emit(title, price, group_id)
