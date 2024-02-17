class_name SelectProductGroupButton extends PanelContainer

var title : String
var id : int

signal group_selected

@onready var button = $SelectProductGroupButton
@onready var highlight = $Control/Control/MarginContainer/Panel

func set_values(_title, _id):
	title = _title
	id = _id

func _ready():
	button.text = title

func select():
	highlight.visible = true
	
func deselect():
	highlight.visible = false

func _on_select_product_group_button_pressed():
		group_selected.emit(id)
