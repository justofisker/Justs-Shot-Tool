extends LineEdit

@export var auto_complete_assistant: AutoCompleteAssistant

func _ready() -> void:
	var terms : Array[String]
	terms.assign(ProjectileManager.objects.keys())
	auto_complete_assistant.load_terms(terms, true)
