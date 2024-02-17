class_name Addition extends Control

var title : String
var price : float

signal pressed

@onready var label = $MarginContainer/Label

func set_values(_title, _price):
	title = _title
	price = _price
	
func _ready():
	label.set_text(title)

func _on_button_pressed():
	pressed.emit(self)
