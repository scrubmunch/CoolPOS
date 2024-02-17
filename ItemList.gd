extends GridContainer

@onready var scroll_container = $".."

func _on_child_entered_tree(node):
	node.modifier_added.connect(modifier_added)
	scroll_to_bottom()

func modifier_added():
	scroll_to_bottom()

func scroll_to_bottom():
	var max_value = scroll_container.get_v_scroll_bar().get_max()
	for i in range(2):
		await get_tree().process_frame
	scroll_container.set_v_scroll(max_value)
