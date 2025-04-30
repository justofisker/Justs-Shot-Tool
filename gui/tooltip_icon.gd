extends TextureRect

func _make_custom_tooltip(for_text):
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.push_font(preload("res://font/Roboto/Roboto-VariableFont_wdth,wght.ttf"))
	label.append_text(for_text)
	label.pop()
	return label
