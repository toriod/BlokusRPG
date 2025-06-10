extends Node2D


# Declare member variables here. Examples:
@export var occupied = false
@export var slot_id = 0
signal mouse_in_slot(slot_pos,slot_id)
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	occupied = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_mouse_entered():
	mouse_in_slot.emit(position,slot_id)
	#print(position)
