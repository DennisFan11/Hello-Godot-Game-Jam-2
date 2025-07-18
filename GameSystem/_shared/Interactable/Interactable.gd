class_name Interactable
extends Area2D

func enable()-> void:
	%RichTextLabel.visible = true
func disable()-> void:
	%RichTextLabel.visible = false

func interact()-> void:
	pass
	
