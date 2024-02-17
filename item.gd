class_name Item extends Control

signal delete_item
signal modifier_deleted
signal item_selected

signal modifier_added

@onready var label = $VBoxContainer/HBoxContainer/MarginContainer2/Label
@onready var container = $VBoxContainer
@onready var highlight = $Control/ColorRect2

var title : String
var price : float
var modifiers : Array
var group_id : int

func set_values(_title : String, _price : float, _group_id : int):
	title = _title
	price = _price
	group_id = _group_id

func _ready():
	label.set_text(title)
	
	size = Vector2(1920, 400)

func add_modifier(_modifier : Modifier):
	modifiers.append(_modifier)
	price += _modifier.price
	container.add_child(_modifier)
	_modifier.delete_modifier.connect(modifier_delete_pressed)
	
	modifier_added.emit()
	
func remove_modifier(_modifier):
	modifiers.erase(_modifier)
	price -= _modifier.price
	_modifier.queue_free()
	modifier_deleted.emit()
	
func modifier_delete_pressed(_modifier):
	remove_modifier(_modifier)
	
func select():
	highlight.visible = true

func deselect():
	highlight.visible = false

func _on_label_pressed():
	item_selected.emit(self)

func _on_button_pressed():
	delete_item.emit(self)
