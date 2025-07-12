class_name MessageBox
extends Node2D

func set_string(string: String):
	%RichTextLabel.text = string
	#print("set Message")
