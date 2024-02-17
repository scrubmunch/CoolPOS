class_name Modifier extends MarginContainer

signal delete_modifier

@onready var label = $HBoxContainer2/Label

var title : String
var price : float

func set_values(_title : String, _price : float):
	title = _title
	price = _price

func _ready():
	label.set_text(title)

func _on_delete_pressed():
	delete_modifier.emit(self)
