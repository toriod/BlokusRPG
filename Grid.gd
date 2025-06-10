class_name Grid
extends Node2D

#@export var outside_height: int = 22
#@export var outside_width: int = 24
#@export var width: int = 20
#@export var height: int = 20
#@export var cell_size: int = 48
#@export var slot_scene: PackedScene
#
## Declare member variables here. Examples:
#var grid: Dictionary = {}
#var show_debug: bool = true
#
#func generateGrid():
	#for x in width:
		#for y in height:
			#grid[Vector2(x,y)] = null
			#if show_debug:
				#var slot = slot_scene.instantiate()
				#slot.position = gridToWorld(Vector2(x,y))+Vector2(outside_width,outside_height)
				#add_child(slot)
				#slot.mouse_in_slot.connect(_on_mouse_in_slot)
				##slot.scale = Vector2(cell_size, cell_size)
				##var rect = ReferenceRect.new()
				##rect.position = gridToWorld(Vector2(x,y))+Vector2(outside_width,outside_height)
				##rect.size = Vector2(cell_size, cell_size)
				##rect.editor_only = false
				##add_child(rect)
				#var label = Label.new()
				#label.position = gridToWorld(Vector2(x,y))+Vector2(outside_width,outside_height)
				#label.text = str(Vector2(x,y))
				#add_child(label)
			#
#func gridToWorld(_pos: Vector2) -> Vector2:
	#return (_pos * cell_size)
	#
#func worldToGrid(_pos: Vector2) -> Vector2:
	#return (_pos/cell_size).floor()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
#func _on_mouse_in_slot(slot_pos):
	##mouse_in_slot2.emit(slot_pos)
	#print(slot_pos)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
