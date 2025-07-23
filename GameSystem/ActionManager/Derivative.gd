class_name Derivative
extends Node2D

var summoner:Node2D:
	set = set_summoner

signal summoner_changed

func set_summoner(value:Node2D):
	if summoner != value:
		summoner = value
		summoner_changed.emit(value)
		return true
	return false
