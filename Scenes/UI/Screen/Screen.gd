class_name Screen
extends Control

func enter() -> void:
	set_process_input(true)
	set_process_unhandled_input(true)

func exit() -> void:
	set_process_input(false)
	set_process_unhandled_input(false)
	recursive_release_focus()

func recursive_release_focus() -> void:
	release_focus()
	for descendant in find_children("*", "Control"):
		descendant.release_focus()
