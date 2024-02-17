class_name ProductGroup extends Control

@onready var grid = $%Grid

var title : String
var id : int

func set_values(_id, _title):
	id = _id
	title = _title
	name = _title

func add_product(p):
	grid.add_child(p)
