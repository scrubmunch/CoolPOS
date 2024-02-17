extends Control

var db : SQLite = null
var db_path = "res://database/database.db"

var Product = preload("res://product.tscn")
var Item = preload("res://item.tscn")
var ProductGroup = preload("res://product_group.tscn")
var Addition = preload("res://addition.tscn")
var Modifier = preload("res://modifier.tscn")
var ProductPlaceholder = preload("res://product_placeholder.tscn")

@onready var groups_container = $%Groups
@onready var item_list = $%ItemList
@onready var name_input = $%NameInput
@onready var dinein_takeaway_switch = $%DITAswitch
@onready var notes_input = $%NotesInput
@onready var additions_container = $%Additions
@onready var price_label = $%PriceLabel
@onready var product_pages = $%ProductPages

var product_groups_dictionary : Dictionary

var selected_item : Item = null

const items_per_page = 28

var order_id : int

class Order:
	var items : Array 
	var total : float = 0
	var time : String
	var customer_name : String
	var dinein_takeaway : String
	var text : String
	var payment_method : String
	
var order : Order
var kitchen_docket : String = ""

var colours = [
	'#f4a628', '#f19e14',
	'#ef9700', '#e99000', '#e38900', '#dd8300', '#d77c00', '#d17500',
	'#cc6f00', '#cc6800', '#cc6200', '#cc5c00', '#cc5600', '#cc5000',
	'#cd4a00', '#b24100', '#983800', '#7e2f00', '#642600', '#4a1d00'
]

func _ready():
	
	db = SQLite.new()
	db.path = db_path
	db.open_db()
	
	db.query("SELECT MAX(id) AS highest_id FROM Orders")
	order_id = db.query_result[0]["highest_id"]
	
	db.query("SELECT * FROM Groups")
	var groups = db.query_result
	for group in groups:
		create_group(group["ID"], group["Name"])
		
		db.query("SELECT * FROM Products WHERE GroupID = %d" % group["ID"])
		var products = db.query_result
		if products != []:
			products.sort_custom(compare_products)

			for i in range(items_per_page):
				var p = find_product_by_position(products, i)
				if p == null:
					var placeholder = ProductPlaceholder.instantiate()
					product_groups_dictionary[group["ID"]].add_product(placeholder)
					
				else:
					create_product(p["Name"], p["Price"], p["GroupID"], colours[i])
		
	db.query("SELECT * FROM Additions")
	for addition in db.query_result:
		create_addition(addition["Name"], addition["Price"])

	order = Order.new()
	
	# Probably shouldn't do this here but oh well
	product_groups_dictionary[1].visible = true
	
func compare_products(a, b):
	if a["Position"] < b["Position"]:
		return true
	else:
		return false

func find_product_by_position(products_array, pos):
	for dict in products_array:
		if dict["Position"] == pos:
			return dict
	return null

func create_group(_id : int, _title : String):
	var g = ProductGroup.instantiate()
	g.set_values(_id, _title)
	product_pages.add_product_group(g)
	product_groups_dictionary[_id] = g
	
func create_product(_title : String, _price : float, _group_id : int, _color : String):
	var p = Product.instantiate()
	p.set_values(_title, _price, _group_id, _color)
	product_groups_dictionary[_group_id].add_product(p)
	p.pressed.connect(product_pressed)

func product_pressed(_title, _price, _group_id):
	create_item(_title, _price, _group_id)
	
func create_addition(_title : String, _price : float):
	var a = Addition.instantiate()
	a.set_values(_title, _price)
	additions_container.add_child(a)
	a.pressed.connect(addition_pressed)
	
func addition_pressed(addition):
	if selected_item != null:
		var m = Modifier.instantiate()
		m.set_values(addition.title, addition.price)
		selected_item.add_modifier(m)
		selected_item.modifier_deleted.connect(modifier_deleted)
		calc_total()
		
func _on_note_text_submitted(new_text):
	if selected_item != null:
		var m = Modifier.instantiate()
		m.set_values(new_text, 0)
		selected_item.add_modifier(m)
		selected_item.modifier_deleted.connect(modifier_deleted)
		notes_input.text = ""

func modifier_deleted():
	calc_total()
	
func create_item(_title : String, _price : float, _group_id : int):
	var i = Item.instantiate()
	i.set_values(_title, _price, _group_id)
	i.delete_item.connect(item_deleted)
	i.item_selected.connect(item_selected)
	
	item_list.add_child(i)
	order.items.append(i)
	select_item(i)

	calc_total()

func select_item(item : Item):
	if selected_item != null:
		selected_item.deselect()
	item.select()
	selected_item = item

func item_deleted(item):
	order.items.erase(item)
	item.queue_free()
	calc_total()

func item_selected(item):
	select_item(item)
	
func calc_total():
	order.total = 0
	for item in order.items:
		order.total += item.price
	price_label.set_text("$" + "%.2f" % order.total)

func _on_cash_pressed():
	order.payment_method = "Cash"
	send_order()

func _on_card_pressed():
	order.payment_method = "Card"
	send_total_to_eftpos()
	send_order()

func send_order():
	if order.total != 0:
		order.customer_name = name_input.text
		order.time = Time.get_time_string_from_system()
		if dinein_takeaway_switch.button_pressed == false:
			order.dinein_takeaway = "Dine In"
		else:
			order.dinein_takeaway = "Takeaway"

		print_order()
		send_order_to_database()
		new_order()

func print_order():
	order.text += "          COFFEE SHOP\n\n"
	order.text += "  Time: " + order.time + "  ID:" + str(order_id) + "\n"
	order.text += "  " + order.dinein_takeaway + "  --  " + order.customer_name + "\n"
	order.text += "  ----------------------|-----\n"
	
	var groups = {}
	for item in order.items:
		if not groups.has(item.group_id):
			groups[item.group_id] = []
		groups[item.group_id].append(item)
		
	var group_keys = groups.keys()
	group_keys.sort()
	var groups_sorted = {}
	for key in group_keys:
		groups_sorted[key] = groups[key]

	for group_id in groups_sorted.keys():
		for item in groups_sorted[group_id]:
			var number_of_spaces = 22 - len(item.title)
			order.text += "  " + item.title
			for space in number_of_spaces:
				order.text += " "
			
			if item.price < 10:
				order.text += "| %.2f\n" % item.price
			else:
				order.text += "|%.2f\n" % item.price
				
			for modifier in item.modifiers:
				
				if len(modifier.title) > 19:
					order.text += "    -" + modifier.title.substr(0, 19) + "|     \n"
					order.text += "     " + modifier.title.substr(19)
					number_of_spaces = 19 - len(modifier.title.substr(19))
					for space in number_of_spaces:
						order.text += " "
					order.text += "|     \n"
				else:
					order.text += "    -" + modifier.title
					number_of_spaces = 19 - len(modifier.title)
					for space in number_of_spaces:
						order.text += " "
					order.text += "|     \n"
				
		order.text += "  ----------------------|-----\n"
		
		if (group_id == 4):
			for item in groups_sorted[group_id]:
				kitchen_docket += item.title + "\n"
				for modifier in item.modifiers:
					kitchen_docket += "   -" + modifier.title + "\n"

	order.text += "  Total: %.2f" % order.total
	print(order.text)
	print_text(order.text)
	
func print_kitchen_docket():
	if (kitchen_docket != ""):
		var docket_text : String = "Name: " + order.customer_name + "\n"
		docket_text += "------------"
		docket_text += kitchen_docket
		print_text(docket_text)

func print_text(text : String):
	var path = "/tmp/output.txt"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()

	var output = []
	var exit_code = OS.execute("lp", [path], output, true)
	print(output)

	if exit_code != 0:
		print("Failed to print the file. Exit code: " + str(exit_code))

func send_order_to_database():
	var dictionary : Dictionary = Dictionary()

	dictionary["Date"] = Time.get_date_string_from_system()
	dictionary["Time"] = Time.get_time_string_from_system()
	dictionary["Total"] = order.total
	dictionary["Data"] = order.text
	dictionary["PaymentMethod"] = order.payment_method

	db.insert_row("Orders", dictionary)

func new_order():
	order = Order.new()
	price_label.set_text("$0.00")
	name_input.text = ""
	dinein_takeaway_switch.button_pressed = false
	order_id += 1
	kitchen_docket = ""
	
	for item in item_list.get_children():
		item.queue_free()

func send_total_to_eftpos():
	pass
