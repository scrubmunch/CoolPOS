extends Control

@onready var group_container = $Panel/MarginContainer/Control/ProductGroupContainer
@onready var button_container = $"Panel/MarginContainer/Control/Swap Tab/MarginContainer/ButtonContainer"

var select_product_group_button = preload("res://select_product_group_button.tscn")

var groups_dictionary : Dictionary
var buttons_dictionary : Dictionary

var selected_group_id = 1

func add_product_group(product_group):
	group_container.add_child(product_group)
	
	var b = select_product_group_button.instantiate()
	
	b.set_values(product_group.title, product_group.id)
	b.group_selected.connect(select_group_button_pressed)
	button_container.add_child(b)
	
	buttons_dictionary[b.id] = b
	
	groups_dictionary[product_group.id] = product_group
	
	if b.id != 1:
		b.deselect()
	
func select_group_button_pressed(id):
	groups_dictionary[selected_group_id].visible = false
	groups_dictionary[id].visible = true
	
	buttons_dictionary[selected_group_id].deselect()
	buttons_dictionary[id].select()
	
	selected_group_id = id
