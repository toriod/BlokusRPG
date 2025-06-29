extends ColorPickerButton

func _get_drag_data(_pos):
	# Use another colorpicker as drag preview.
	var cpb = ColorPickerButton.new()
	cpb.color = color
	cpb.size = Vector2(50, 50)
	set_drag_preview(cpb)
	# Return color as drag data.
	return color


func _can_drop_data(_pos, data):
	return typeof(data) == TYPE_COLOR


func _drop_data(_pos, data):
	color = data
