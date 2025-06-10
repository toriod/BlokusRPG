extends CharacterBody2D

var dragging = false
@export var num = 0 #number of tile in the piece
@export var draggable = true
@export var tilepos = Vector2(0,0) #integer position of tile compared to tile 1
@export var hiddenTile = false
@export var placeable = true
@export var biome = 1
var mouse_on_board #for snapping while dragging
var num_drag #basically num
var rand_num #random tile look
var slot_pos = Global.slot_pos

signal dragsignal(num) #emitted when tile is clicked on
signal right_click_on_tile() #turning
signal middle_click_on_tile() #flipping

func _ready():
	connect("dragsignal", Callable(self, "_set_drag_pc"))
	rand_num = randi() % 2
	
	
func _process(delta):
	if rand_num == 0:
		if biome == 1:
			$Sand.texture = load("res://sand tile 1.png")
		elif biome == 2:
			$Sand.texture = load("res://lava tile 1.png")
		elif biome == 3:
			$Sand.texture = load("res://water tile 1.png")
		elif biome == 4:
			$Sand.texture = load("res://grass tile 1.png")
	else:
		if biome == 1:
			$Sand.texture = load("res://sand tile 2.png")
		elif biome == 2:
			$Sand.texture = load("res://lava tile 2.png")
		elif biome == 3:
			$Sand.texture = load("res://water tile 2.png")
		elif biome == 4:
			$Sand.texture = load("res://grass tile 2.png")

	mouse_on_board = Global.mouse_on_board
	if dragging:
		slot_pos = Global.slot_pos
		placeable = placeable and mouse_on_board and (Global.board_state_array[Global.slot_id] == 0)
		if placeable:
			self.position = slot_pos
		else:
			var mousepos = get_viewport().get_mouse_position()
		#var mousepos = get_local_mouse_position()
			self.position = Vector2(mousepos.x, mousepos.y) - $CollisionShape2D.shape.get_rect().size/2
		#$CollisionShape2D.position = self.position 

		
	

func _set_drag_pc(num_drag):
	dragging=!dragging



func _on_Piece_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if draggable:
				dragsignal.emit(num)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			right_click_on_tile.emit()
		elif event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			middle_click_on_tile.emit()
		#	emit_signal("dragsignal")
		#	print(dragging)
	#elif event is InputEventScreenTouch:
		#if event.pressed and event.get_index() == 0:
			#self.position = event.get_position()


#func _on_board_area_mouse_exited():
	#mouse_on_board = false
	#print("board entered")
#
#
#func _on_board_area_mouse_entered():
	#mouse_on_board = true
	#print("board exited")


#func _on_blokus_board_mouse_in_slot_2(slot_pos):
	#print("tile level ",slot_pos)
