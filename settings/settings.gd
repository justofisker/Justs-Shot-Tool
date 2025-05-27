extends Node

signal setting_changed(property: String)

var background_color := Color("4d4d4d")
var grid_color := Color("5a5a5a")
var grid_enabled := true
var object_color := Color.WHITE
var object_selected_color := Color.GREEN
var projectile_path_color := Color.BLACK
var projectile_color := Color.WHITE

const SETTINGS_FILE := "user://settings.json"

func _ready() -> void:
	load_settings()
	setting_changed.connect(func(_property: String): save_settings())

func save_settings() -> void:
	var dict := {}
	for property in get_property_list():
		if property["usage"] == PROPERTY_USAGE_SCRIPT_VARIABLE:
			var property_name : String = property["name"]
			var value = get(property_name)
			if value is Color:
				dict[property_name] = value.to_html(false)
			else:
				dict[property_name] = value
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(dict, "\t") + "\n")

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_FILE):
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		var json = JSON.new()
		json.parse(file.get_as_text())
		
		if json.data is Dictionary:
			for key in json.data.keys():
				if key in Settings:
					if get(key) is Color:
						set(key, Color.from_string(json.data[key], get(key)))
					else:
						set(key, json.data[key])
