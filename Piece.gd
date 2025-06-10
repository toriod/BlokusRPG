extends Node2D

var dragging = false
var size = 48
var num_drag
var selectedTile
var button_node
#hopefully way to program each piece on the blockus board level
@export var layout = {"Tile1x": 0, "Tile2x":0,"Tile3x":1,"Tile4x":2,"Tile5x":3, \
	"Tile1y": 0, "Tile2y":1,"Tile3y":1,"Tile4y":1,"Tile5y":1}
@export var num_piece = 0
@export var piece_size = 5
@export var player_affiliation = 1
@export var CEAscore = 12
@export var placed = false
@export var corner_list = []
@export var corner_dir = [] #each diagonal diraction has a number
signal dragging_piece(num_piece,num_drag)

func _ready():
	#give tiles a biome
	$Tile1.biome = player_affiliation
	$Tile2.biome = player_affiliation
	$Tile3.biome = player_affiliation
	$Tile4.biome = player_affiliation
	$Tile5.biome = player_affiliation
	
	if piece_size <= 4:
		$Tile5.hiddenTile = true
		$Tile5.visible = false
	if piece_size <= 3:
		$Tile4.hiddenTile = true
		$Tile4.visible = false
	if piece_size <= 2:
		$Tile3.hiddenTile = true
		$Tile3.visible = false
	if piece_size <= 1:
		$Tile2.hiddenTile = true
		$Tile2.visible = false
	#put tiles in position
	$Tile1.tilepos = Vector2(layout["Tile1x"],layout["Tile1y"])
	$Tile2.tilepos = Vector2(layout["Tile2x"],layout["Tile2y"])
	$Tile3.tilepos = Vector2(layout["Tile3x"],layout["Tile3y"])
	$Tile4.tilepos = Vector2(layout["Tile4x"],layout["Tile4y"])
	$Tile5.tilepos = Vector2(layout["Tile5x"],layout["Tile5y"])

	$Tile1.position = $Tile1.tilepos*size
	$Tile2.position = $Tile2.tilepos*size
	$Tile3.position = $Tile3.tilepos*size
	$Tile4.position = $Tile4.tilepos*size
	$Tile5.position = $Tile5.tilepos*size
	
	#connect all tile signals to this script's routine
	connect_signals(get_node("Tile1"))
	connect_signals(get_node("Tile2"))
	connect_signals(get_node("Tile3"))
	connect_signals(get_node("Tile4"))
	connect_signals(get_node("Tile5"))
	Global.confirm_placement.connect(_on_confirm_placement_button_pressed)
	
	find_corners()
	
func connect_signals(tempTile):
	tempTile.dragsignal.connect(_on_dragsignal)
	tempTile.right_click_on_tile.connect(_on_right_click_on_tile)
	tempTile.middle_click_on_tile.connect(_on_middle_click_on_tile)
	
	
	
func _process(delta):
	if dragging:
		var dragpos = selectedTile.position - selectedTile.tilepos*size #laggy
		$Tile1.position = $Tile1.tilepos*size +dragpos
		$Tile2.position = $Tile2.tilepos*size +dragpos
		$Tile3.position = $Tile3.tilepos*size +dragpos
		$Tile4.position = $Tile4.tilepos*size +dragpos
		$Tile5.position = $Tile5.tilepos*size +dragpos
		#moving the other tiles with the dragged tile
		if(Global.mouse_on_board):
			var isdiagonal = false
			selectedTile.placeable = true #determining if the piece is hovered over a placeable spot
			selectedTile.placeable = placement_rules($Tile1,selectedTile.placeable)
			selectedTile.placeable = placement_rules($Tile2,selectedTile.placeable)
			selectedTile.placeable = placement_rules($Tile3,selectedTile.placeable)
			selectedTile.placeable = placement_rules($Tile4,selectedTile.placeable)
			selectedTile.placeable = placement_rules($Tile5,selectedTile.placeable)
			isdiagonal = diagonal_check($Tile1,isdiagonal)
			isdiagonal = diagonal_check($Tile2,isdiagonal)
			isdiagonal = diagonal_check($Tile3,isdiagonal)
			isdiagonal = diagonal_check($Tile4,isdiagonal)
			isdiagonal = diagonal_check($Tile5,isdiagonal)
			if !isdiagonal:
				selectedTile.placeable = false

func placement_rules(tempTile,placeable):
	var x_translation = round(tempTile.tilepos[0]-selectedTile.tilepos[0])
	var y_translation = round(tempTile.tilepos[1]-selectedTile.tilepos[1])
	var array_pos = Global.slot_id+x_translation+Global.board_width*y_translation #array position of temptile
	var array_x_pos = Global.slot_id % 20 + x_translation
	var array_y_pos = (Global.slot_id - (Global.slot_id % 20))/20 + y_translation
	var out_of_bounds = array_x_pos < 0 or array_x_pos >= Global.board_width \
		or array_y_pos < 0 or array_y_pos >= Global.board_height #check if tile is out of bounds
	if out_of_bounds:
		placeable = false
	else:
		placeable = placeable and Global.board_state_array[array_pos] == 0 #check if tile is occupied
	##check if tile is next to tile of the same player
	if array_x_pos > 0:
		placeable = placeable and Global.board_state_array[array_pos-1] != player_affiliation
	if array_x_pos < Global.board_width-1:
		placeable = placeable and Global.board_state_array[array_pos+1] != player_affiliation
	if array_y_pos > 0:
		placeable = placeable and Global.board_state_array[array_pos-Global.board_width] != player_affiliation
	if array_y_pos < Global.board_height-1:
		placeable = placeable and Global.board_state_array[array_pos+Global.board_width] != player_affiliation
	
	return placeable
	
func diagonal_check(tempTile,isdiagonal):
	var x_translation = round(tempTile.tilepos[0]-selectedTile.tilepos[0])
	var y_translation = round(tempTile.tilepos[1]-selectedTile.tilepos[1])
	var array_pos = Global.slot_id+x_translation+Global.board_width*y_translation #array position of temptile
	var array_x_pos = Global.slot_id % 20 + x_translation
	var array_y_pos = (Global.slot_id - (Global.slot_id % 20))/20 + y_translation
	##check if we are diagonally touching another piece of ours
	if array_y_pos < Global.board_height-1 and array_y_pos > -1:
		if array_x_pos < Global.board_width-1 and array_x_pos > -1:
			isdiagonal = isdiagonal or Global.board_state_array[array_pos+1+Global.board_width] == player_affiliation
		if array_x_pos > 0 and array_x_pos < Global.board_width:
			isdiagonal = isdiagonal or Global.board_state_array[array_pos-1+Global.board_width] == player_affiliation
	if array_y_pos > 0 and array_y_pos < Global.board_height:
		if array_x_pos < Global.board_width-1 and array_x_pos > -1:
			isdiagonal = isdiagonal or Global.board_state_array[array_pos+1-Global.board_width] == player_affiliation
		if array_x_pos > 0 and array_x_pos < Global.board_width:
			isdiagonal = isdiagonal or Global.board_state_array[array_pos-1-Global.board_width] == player_affiliation
	##check if we are in the corner
	if player_affiliation == 1: #bottom left
		isdiagonal = isdiagonal or array_pos == Global.board_height*Global.board_width -1
	if player_affiliation == 2: #bottom left
		isdiagonal = isdiagonal or array_pos == Global.board_height*(Global.board_width-1)
	if player_affiliation == 3: #top left
		isdiagonal = isdiagonal or array_pos == 0
	if player_affiliation == 4: #top right
		isdiagonal = isdiagonal or array_pos == Global.board_width-1
		
	return isdiagonal

func _on_dragsignal(num_drag):
	position = Vector2(0,0)
	dragging_piece.emit(num_piece,num_drag) #this signal goes to blokus
	dragging = !dragging
	if dragging:
		modulate = Color(1,1,1,1)
		#tested method for making putting down a tile not pick up
		#sorta worked but was sorta random if it worked???
		#$Tile1.draggable = false
		#$Tile2.draggable = false
		#$Tile3.draggable = false
		#$Tile4.draggable = false
		#$Tile5.draggable = false
		
		#figure out which tile is dragged
		selectedTile = get_child(num_drag-1)
		#if num_drag == 1: 
			#selectedTile = get_node("Tile1")
		#if num_drag == 2: 
			#selectedTile = get_node("Tile2")
		#if num_drag == 3: 
			#selectedTile = get_node("Tile3")
		#if num_drag == 4: 
			#selectedTile = get_node("Tile4")
		#if num_drag == 5: 
			#selectedTile = get_node("Tile5")
		#selectedTile.draggable = true
		#print(num_drag)
	else:
		if Global.mouse_on_board and selectedTile.placeable == true:
			Global.selected_piece = num_piece
			Global.selected_slot_id = Global.slot_id
			Global.selected_tile = num_drag
			print("selected piece: ",Global.selected_piece)
			print("selected slot: ",Global.selected_slot_id)
			print("selected tile: ",Global.selected_tile)
		#$Tile1.draggable = true
		#$Tile2.draggable = true
		#$Tile3.draggable = true
		#$Tile4.draggable = true
		#$Tile5.draggable = true
		
		elif Global.mouse_on_board and selectedTile.placeable == false:
			modulate = Color(1,0,0,1)

#func round_to_dec(num, digit):
	#return round(num * pow(10.0, digit)) / pow(10.0, digit)
	
			
func rotate_piece(overwrite):
	if dragging or overwrite:
		$Tile1.tilepos = $Tile1.tilepos.rotated(PI/2)
		$Tile2.tilepos = $Tile2.tilepos.rotated(PI/2)
		$Tile3.tilepos = $Tile3.tilepos.rotated(PI/2)
		$Tile4.tilepos = $Tile4.tilepos.rotated(PI/2)
		$Tile5.tilepos = $Tile5.tilepos.rotated(PI/2)
		
func flip_piece(overwrite):
	if dragging or overwrite:
		$Tile1.tilepos = $Tile1.tilepos*Vector2(-1,1)
		$Tile2.tilepos = $Tile2.tilepos*Vector2(-1,1)
		$Tile3.tilepos = $Tile3.tilepos*Vector2(-1,1)
		$Tile4.tilepos = $Tile4.tilepos*Vector2(-1,1)
		$Tile5.tilepos = $Tile5.tilepos*Vector2(-1,1)


func _on_right_click_on_tile():
	rotate_piece(false)
	
func _on_middle_click_on_tile():
	flip_piece(false)


func _on_confirm_placement_button_pressed():
	if Global.selected_piece == num_piece:
		$Tile1.draggable = false
		$Tile2.draggable = false
		$Tile3.draggable = false
		$Tile4.draggable = false
		$Tile5.draggable = false
		placed = true
		
		fill_board_array($Tile1)
		if piece_size >= 2:
			fill_board_array($Tile2)
		if piece_size >= 3:
			fill_board_array($Tile3)
		if piece_size >= 4:
			fill_board_array($Tile4)
		if piece_size >= 5:
			fill_board_array($Tile5)
			
func find_corners():
	for i in piece_size: #each tile
		var ichild=get_child(i)
		var upright=true #is upper right corner valid #3
		var downright = true #2
		var upleft = true #0
		var downleft = true #1
		for j in piece_size:
			var jchild = get_child(j)
			if jchild.tilepos[0] - ichild.tilepos[0] == -1:
				if jchild.tilepos[1] - ichild.tilepos[1] == -1:
					upleft = false
				elif jchild.tilepos[1] - ichild.tilepos[1] == 0:
					upleft = false
					downleft = false
				elif jchild.tilepos[1] - ichild.tilepos[1] == 1:
					downleft = false
			elif jchild.tilepos[0] - ichild.tilepos[0] == 0:
				if jchild.tilepos[1] - ichild.tilepos[1] == -1:
					upleft = false
					upright = false
				elif jchild.tilepos[1] - ichild.tilepos[1] == 1:
					downleft = false
					downright = false
			elif jchild.tilepos[0] - ichild.tilepos[0] == 1:
				if jchild.tilepos[1] - ichild.tilepos[1] == -1:
					upright = false
				elif jchild.tilepos[1] - ichild.tilepos[1] == 0:
					upright = false
					downright = false
				elif jchild.tilepos[1] - ichild.tilepos[1] == 1:
					downright = false
		#do I want a list of the corners?  or a list of the tiles with the corner directions
		if upleft: 
			corner_list.append(i)
			corner_dir.append(0)
		if downleft: 
			corner_list.append(i)
			corner_dir.append(1)
		if downright: 
			corner_list.append(i)
			corner_dir.append(2)
		if upright: 
			corner_list.append(i)
			corner_dir.append(3)
	#print(corner_list)
	#print(corner_dir)


func fill_board_array(tempTile):
	var x_translation = round(tempTile.tilepos[0]-selectedTile.tilepos[0])
	var y_translation = round(tempTile.tilepos[1]-selectedTile.tilepos[1])
	var array_pos = Global.selected_slot_id+x_translation+Global.board_width*y_translation
	Global.board_state_array[array_pos] = player_affiliation
	
func move_piece(location,direction,tile,orientation):
	for i in orientation%10: #orient tile
		rotate_piece(true)
	if orientation>=10: 
		if (direction % 2 == 1): #flip different ways based on corner direction
			flip_piece(true)
			rotate_piece(true)
		elif(direction % 2 == 0):
			rotate_piece(true)
			flip_piece(true)
	Global.selected_piece = num_piece
	Global.selected_slot_id = location
	Global.selected_tile = tile
	selectedTile = get_child(tile)
	print("selected piece: ",Global.selected_piece)
	print("selected slot: ",Global.selected_slot_id)
	#print("selected tile: ",Global.selected_tile)
	var dragpos = Global.selected_slot_pos - selectedTile.tilepos*size - position #laggy
	$Tile1.position = $Tile1.tilepos*size +dragpos
	$Tile2.position = $Tile2.tilepos*size +dragpos
	$Tile3.position = $Tile3.tilepos*size +dragpos
	$Tile4.position = $Tile4.tilepos*size +dragpos
	$Tile5.position = $Tile5.tilepos*size +dragpos
	
