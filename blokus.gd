extends Node2D

var dragging = false
var mouse_on_board
var num_pieces = [21,21,21,21]
var playersout = [false,false,false,false,false]
var player_scores = [0,0,0,0,0] #first one unused
signal next_turn()


## TO DO
##piece rotation
##piece selection rules
##make all pieces
##locking in pieces in the board
##piece placement rules
##UI


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.turn = 1
	Global.round = 1
	#for i in 100:
		#if playersout[1] == true and playersout[2] == true and playersout[3] == true and playersout[4] == true:
			#playersout[0] == true
			#print('game over')
		#else:
			#next_turn.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(dragging):
		var mousepos = get_viewport().get_mouse_position()
		#snapping the dragging
		#$Tile.position = mouse_slot_pos
		#print(mouse_slot_pos)

#
#func _on_piece_dragsignal():
	#dragging=!dragging


func _on_piece_dragging_piece(num_piece, num_drag):
	dragging=!dragging
	


func _on_board_area_mouse_entered():
	Global.mouse_on_board = true
	#print(Global.mouse_on_board)


func _on_board_area_mouse_exited():
	Global.mouse_on_board = false
	#print(Global.mouse_on_board)


func _on_confirm_placement_button_pressed():
	Global.emit_signal("confirm_placement")
	if Global.turn == 1:
		next_turn.emit()


func _on_next_turn():
	Global.turn += 1
	if Global.turn == 5:
		Global.turn = 1
		Global.round += 1
	if Global.turn == 2 or Global.turn == 3 or Global.turn == 4:
		if playersout[1] == true and playersout[2] == true and playersout[3] == true and playersout[4] == true:
			playersout[0] == true #flag i havn't used
			print('game over')
			calculate_scores()
		else:
			ai_turn()
			next_turn.emit()
	elif Global.turn == 1 and playersout[1] == true:
		print('player 1 turn skipped')
		next_turn.emit()
		
		
func calculate_scores():
	for ichild in get_child_count():
		if(get_child(ichild).has_method("rotate_piece")):
			var ipiece = get_child(ichild)
			if(ipiece.placed==false): #loop through each unplaced piece
					player_scores[ipiece.player_affiliation] += ipiece.piece_size #score is the amount of tiles
	$GameEndScores.add_text('SCORES: (golf rules)\nPlayer 1 (you): ')
	$GameEndScores.add_text(str(player_scores[1]))
	$GameEndScores.add_text('\nPlayer 2: ')
	$GameEndScores.add_text(str(player_scores[2]))
	$GameEndScores.add_text('\nPlayer 3: ')
	$GameEndScores.add_text(str(player_scores[3]))
	$GameEndScores.add_text('\nPlayer 4: ')
	$GameEndScores.add_text(str(player_scores[4]))
	if player_scores[1]<=player_scores[2] and player_scores[1]<=player_scores[3] and player_scores[1]<=player_scores[4]:
		$GameEndScores.add_text('\nYOU WIN!!!!')

func ai_turn():
	if playersout[Global.turn] == false:
		#AI
		print()
		print('starting player ',Global.turn,'s turn')
		#find avail corners
		############################################################################################
		var num_corners = 0
		var corner_locations = []
		var corner_directions = []
		#Global.board_state_array[18] = 1 #debugging
		#Global.board_state_array[399] = 1 #debugging
		#Global.board_state_array[380] = 2
		#Global.board_state_array[0] = 3
		#Global.board_state_array[19] = 4
		for i in Global.board_width:
			for j in Global.board_height:
				var array_pos = i+Global.board_width*j #array position of temptile
				if Global.board_state_array[array_pos] == 0:
					#check if we are in the board corner
					if (Global.turn == 1 and array_pos == Global.board_height*Global.board_width -1):
						num_corners = 1
						corner_locations = [array_pos]
						corner_directions = [2]
					elif (Global.turn == 2 and array_pos == Global.board_height*(Global.board_width-1)):
						num_corners = 1
						corner_locations = [array_pos]
						corner_directions = [3]
					elif (Global.turn == 3 and array_pos == 0):
						num_corners = 1
						corner_locations = [array_pos]
						corner_directions = [0]
					elif (Global.turn == 4 and array_pos == Global.board_width-1):
						num_corners = 1
						corner_locations = [array_pos]
						corner_directions = [1]
					var placeable = true
					var isdiagonal = false
					var corner_direction_bool = true #(has a corner been registered)
					#check adjacent tiles
					if i > 0:
						placeable = placeable and Global.board_state_array[array_pos-1] != Global.turn
					if i < Global.board_width-1:
						placeable = placeable and Global.board_state_array[array_pos+1] != Global.turn
					if j > 0:
						placeable = placeable and Global.board_state_array[array_pos-Global.board_width] != Global.turn
					if j < Global.board_height-1:
						placeable = placeable and Global.board_state_array[array_pos+Global.board_width] != Global.turn
					#check diagonal
					if j < Global.board_height-1 and j > -1:
						if i < Global.board_width-1 and i > -1:
							isdiagonal = isdiagonal or Global.board_state_array[array_pos+1+Global.board_width] == Global.turn
							if placeable and isdiagonal and corner_direction_bool:
								corner_directions.append(2) #corner dir facing: 0=+y,+x;1=+y,-x;2=-y,-x;3=-y,+x
								corner_direction_bool = false
						if i > 0 and i < Global.board_width:
							isdiagonal = isdiagonal or Global.board_state_array[array_pos-1+Global.board_width] == Global.turn
							if placeable and isdiagonal and corner_direction_bool:
								corner_directions.append(3) 
								corner_direction_bool = false
					if j > 0 and j < Global.board_height:
						if i < Global.board_width-1 and i > -1:
							isdiagonal = isdiagonal or Global.board_state_array[array_pos+1-Global.board_width] == Global.turn
							if placeable and isdiagonal and corner_direction_bool:
								corner_directions.append(1) 
								corner_direction_bool = false
						if i > 0 and i < Global.board_width:
							isdiagonal = isdiagonal or Global.board_state_array[array_pos-1-Global.board_width] == Global.turn
							if placeable and isdiagonal and corner_direction_bool:
								corner_directions.append(0) 
								corner_direction_bool = false
					if placeable and isdiagonal:
						num_corners += 1
						corner_locations.append(array_pos)
		print('number of corners: ',num_corners)
		print(corner_locations)
		#print(corner_directions)
		if Global.turn == 1:
			Global.player1corners = corner_locations
		elif Global.turn == 2:
			Global.player2corners = corner_locations
		elif Global.turn == 3:
			Global.player3corners = corner_locations
		elif Global.turn == 4:
			Global.player4corners = corner_locations
		#find placeble pieces
		var num_placables = 0
		var placables_ichilds = []
		for ichild in get_child_count():
			if(get_child(ichild).has_method("rotate_piece")):
				if(get_child(ichild).player_affiliation==Global.turn and get_child(ichild).placed==false):
					num_placables += 1
					placables_ichilds.append(ichild) #store ichild # to quickly access in a loop
		print('number of pieces: ',num_placables)
		print(placables_ichilds)
		
		######################################################################################
		
		#loop over board corners, avail pieces, piece corners, piece flips (~15 x ~20 x ~5 x 2 = 3000 options)
		var num_options = 0
		var options_piece = [] 
		var options_location = [] #the corner location on the grid
		var options_direction = [] #the direction of the corner: 0=+y,+x;1=+y,-x;2=-y,-x;3=-y,+x
		var options_tile = [] #the corner tile of the piece
		var options_orientation = [] #the orientation of the piece: 0=base, 1=rotated once, 2= twice, 3=3x, 10= flipped
		for corner in num_corners: #loop over available board corners
			for ichild in num_placables: #loop over available pieces
				var ipiece = get_child(placables_ichilds[ichild])
				for tile_corner in ipiece.corner_list.size(): #loop over possible corners of each piece
					var itile = ipiece.corner_list[tile_corner]
					ipiece.selectedTile = ipiece.get_child(itile) #select corner tile for placement rules
					Global.slot_id = corner_locations[corner] #select board corner location for placement rules
					var num_rotates = (corner_directions[corner]+ipiece.corner_dir[tile_corner]) % 4
					#num_rotates: number of clockwise turns needed to align corners
					var orientation = num_rotates #0=normal, 1=rotated once, 2= twice, 3=3x, 10= flipped(but maintaining corner)
					for i in num_rotates: #align corners
						ipiece.rotate_piece(true)
					for i in 2: #loop over both flips that preserve the same corner
						var placeable = true
						if (corner_directions[corner] % 2 == 1): #flip different ways based on corner orientation
							ipiece.flip_piece(true)
							ipiece.rotate_piece(true)
						elif(corner_directions[corner] % 2 == 0):
							ipiece.rotate_piece(true)
							ipiece.flip_piece(true)
						if orientation<10:
							orientation += 10;
						else:
							orientation -= 10;
						for j in ipiece.piece_size: #check each tile for if it's placeable
							placeable = ipiece.placement_rules(ipiece.get_child(j),placeable)
						if placeable:
							num_options += 1
							options_piece.append(ipiece)
							options_location.append(corner_locations[corner])
							options_direction.append(corner_directions[corner])
							options_tile.append(itile)
							options_orientation.append(orientation)
							#tally_placement_points(ipiece,corner_locations[corner],corner_directions[corner], \
							#itile,ipiece.corner_dir[tile_corner])
						#print(corner_locations[corner],' ',placables_ichilds[ichild],
						#' ',itile,' ',ipiece.corner_dir[tile_corner],' ',placeable)
					for i in ((4-num_rotates)%4): #rotate back to standard position
						ipiece.rotate_piece(true)
		#add up placement points
		print('number of placement options: ',num_options)
		#print(options_piece)
		#print(options_location)
		#print(options_direction)
		#print(options_tile)
		#print(options_orientation)
		if num_options == 0:
			playersout[Global.turn] = true
			print('player ',Global.turn,' is defeated!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
		else:
		######################################################################################
		
			var pp
			var ppmax = 0
			var best = 0
			for i in num_options:
				pp=tally_placement_points(options_piece[i],options_location[i],options_direction[i], \
				options_tile[i],options_orientation[i])
				if pp > ppmax:
					ppmax = pp
					best = i
					#print(i)
			$BlokusBoard.update_selected_slot_pos(options_location[best])
			options_piece[best].move_piece(options_location[best],options_direction[best], \
				options_tile[best],options_orientation[best])
			options_piece[best]._on_confirm_placement_button_pressed()
		

func placement_rules(old_pos,placeable,x_translation,y_translation):
	var array_pos = old_pos+x_translation+Global.board_width*y_translation #array position of temptile
	var array_x_pos = old_pos % Global.board_width + x_translation
	var array_y_pos = (old_pos - (old_pos % Global.board_width))/Global.board_width + y_translation
	var out_of_bounds = array_x_pos < 0 or array_x_pos >= Global.board_width \
		or array_y_pos < 0 or array_y_pos >= Global.board_height #check if tile is out of bounds
	if out_of_bounds:
		placeable = false
	else:
		placeable = placeable and Global.board_state_array[array_pos] == 0 #check if tile is occupied
	##check if tile is next to tile of the same player
	if array_x_pos > 0:
		placeable = placeable and Global.board_state_array[array_pos-1] != Global.turn
	if array_x_pos < Global.board_width-1:
		placeable = placeable and Global.board_state_array[array_pos+1] != Global.turn
	if array_y_pos > 0:
		placeable = placeable and Global.board_state_array[array_pos-Global.board_width] != Global.turn
	if array_y_pos < Global.board_height-1:
		placeable = placeable and Global.board_state_array[array_pos+Global.board_width] != Global.turn
	
	return placeable


func tally_placement_points(ipiece,corner_location,corner_direction,tile,tile_orientation):
	var pp=0
	#each placement criteria will be evaluated from 0-10, then scaled by these scales
	#advanced: these values change based on board state/how long the game is running
	var sizeScale=2 #how many tiles in piece DONE
	var edgeDistanceScale=1 #how far from opposite edges DONE
	var newCornerScale = 1 #corners created-corners removed DONE
	var pieceDistanceScale = .5 #distance from other pieces SKIP FOR NOW
	var cornersBlokusedScale = 2 # how many enemy corners blocked SKIP FOR NOW
	var gardenWallScale = .5 #did it create a 1- or 2-block island SKIP FOR NOW
	var seepageScale = 1 #how many corners fit in gaps in other walls
	var safeCornerScale = 1 #is the corner directly next to another color
	var selfBlokusScale = 1 #how many spaces did I remove from play for me
	var openSpaceScore = .5 #how many spaces are available in the 3x3s from each corner
	var clunkyPieceScale = .5 #how quickly do I want to get down the piece
	#advanced: avg pp # of placements I can get from the new corners : recursive
	#advanced: predict the placements of opponents to:
	#			*prioritize placing on a spot where I think they will place next
	#			*deprioritize placing on fully safe spots (no opponents can play there)
	if Global.round < 8: #prioritize distance in the early game
		edgeDistanceScale = 3

	
	var corner_tile = ipiece.get_child(tile)
	#ipiece.selectedTile = corner_tile
	#Global.slot_id = corner_location #place tile in spot
	for i in tile_orientation%10: #orient tile
		ipiece.rotate_piece(true)
	var tmp_corner_dir =[]

	for i in ipiece.corner_dir.size():
		tmp_corner_dir.append(posmod(ipiece.corner_dir[i]-(tile_orientation%10),4)) #change corner dir based on rotation
		if tile_orientation>=10:
			if posmod(tmp_corner_dir[i]-corner_direction,2) == 1:
				tmp_corner_dir[i] = (tmp_corner_dir[i]+2)%4
	#print(ipiece.corner_dir,' ', tile_orientation)
	#print(tmp_corner_dir)
	if tile_orientation>=10: 
		if (corner_direction % 2 == 1): #flip different ways based on corner orientation
			ipiece.flip_piece(true)
			ipiece.rotate_piece(true)
			
		elif(corner_direction % 2 == 0):
			ipiece.rotate_piece(true)
			ipiece.flip_piece(true)
			
	var diagonal_offsets=[-1-Global.board_width,-1+Global.board_width,1+Global.board_width,1-Global.board_width]#0,1,2,3
	var x_offsets=[-1,-1,1,1]
	var y_offsets=[-1,1,1,-1]
	var adjacent_offsets = [Global.board_width,1,-Global.board_width,-1] #down, left, up, right
	var x_edge_distance = 0
	var y_edge_distance = 0
	var new_corners = 0
	var removed_corners = 0
	var playerCorners =[]
	playerCorners.clear()
	var safe_corners = 0
	var seep_bonus = 0
	var garden_wall = 0
	if Global.turn == 1:
		playerCorners = Global.player1corners.duplicate()
	elif Global.turn == 2:
		playerCorners = Global.player2corners.duplicate()
	elif Global.turn == 3:
		playerCorners = Global.player3corners.duplicate()
	elif Global.turn == 4:
		playerCorners = Global.player4corners.duplicate()
###########################################################################
	for corner in ipiece.corner_list.size(): #loop over possible corners of selected piece
		var itile = ipiece.corner_list[corner]
		var tile_offset = ipiece.get_child(itile).tilepos
		var x_translation: int = round(tile_offset[0]-corner_tile.tilepos[0])
		var y_translation: int = round(tile_offset[1]-corner_tile.tilepos[1])
		var array_pos = corner_location+x_translation+Global.board_width*y_translation #array position of temptile
		var array_x_pos = corner_location % 20 + x_translation
		var array_y_pos = (corner_location - (corner_location % 20))/20 + y_translation
		var x_direction = x_offsets[tmp_corner_dir[corner]]
		var y_direction = y_offsets[tmp_corner_dir[corner]]
		
		#var new_corner = array_pos + directional_offsets[tmp_corner_dir[piece_corner]] #tile that each corner points to
		var unblocked = true
		unblocked=placement_rules(array_pos,unblocked,x_direction,y_direction)
		if unblocked:
			new_corners += 1
			var half_key = false #collect 2 to form a key
			if(Global.board_state_array[array_pos+x_direction] != 0):#if the piece nestles into the edge or corner of another piece
				if(Global.board_state_array[array_pos+x_direction] == Global.turn):
					print("error in option piece placement rules") #that means two pieces are touching of the same team
				safe_corners +=1 #this enemy cannot place on this corner
				half_key = true
			if(Global.board_state_array[array_pos+y_direction*Global.board_width] != 0):
				if(Global.board_state_array[array_pos+y_direction*Global.board_width] == Global.turn):
					print("error in option piece placement rules") #that means two pieces are touching of the same team
				safe_corners +=1
				if half_key == true: 
					seep_bonus += 1 #seeped through a wall
		else:
			var out_of_bounds = array_x_pos+x_direction < 0 or array_x_pos+x_direction >= Global.board_width \
				or array_y_pos+y_direction < 0 or array_y_pos+y_direction >= Global.board_height #check if tile is out of bounds
			if(!out_of_bounds):
				if(Global.board_state_array[array_pos+x_direction+y_direction*Global.board_width] == Global.turn):
					garden_wall += 1 #if 2 or more, potentially created a 1x1 or other small gap for opponant (maybe not tho?)
			
	for i in ipiece.piece_size: #loop over all tiles in selected piece
		var itile=ipiece.get_child(i)
		var tile_offset = itile.tilepos
		var x_translation = round(tile_offset[0]-corner_tile.tilepos[0])
		var y_translation = round(tile_offset[1]-corner_tile.tilepos[1])
		var array_pos = corner_location+x_translation+Global.board_width*y_translation #array position of temptile
		var array_x_pos = corner_location % 20 + x_translation
		var array_y_pos = (corner_location - (corner_location % 20))/20 + y_translation
		
		x_edge_distance = max(x_edge_distance,array_x_pos)
		y_edge_distance = max(y_edge_distance,array_y_pos)
		
		for k in playerCorners.size(): #loop over possible corners to be cut off (including the one placed on)
			if array_pos == playerCorners[k]:
				removed_corners += 1
				playerCorners[k] = -500 #don't count this again
				continue
			for j in 4: #4 adjacent tiles
				var pos = array_pos + adjacent_offsets[j]
				if pos == playerCorners[k]:
					removed_corners += 1
					playerCorners[k] = -500 #if i have to use this again, I may need to find a new way to code this
					break
		
		
	pp += ipiece.piece_size*2*sizeScale #size pp, max = 5, min = 1
	pp += (new_corners - removed_corners)*newCornerScale #max ~5, min ~-5
	if Global.turn==1 or Global.turn == 2:
		y_edge_distance = Global.board_height - y_edge_distance
	if Global.turn==1 or Global.turn == 4:
		x_edge_distance = Global.board_width - x_edge_distance
	pp += (x_edge_distance+y_edge_distance)/4*edgeDistanceScale #max dis+dis = 40, min = 0
	pp += safe_corners*2*safeCornerScale
	pp += seep_bonus*5*seepageScale
	garden_wall -= 1 #every piece automatically has one, so no need to bonus
	pp += garden_wall*5*gardenWallScale
	
	
	#print(ipiece.num_piece,' ',corner_location,' ', pp, ' ',garden_wall)
		
	if tile_orientation>=10: #reflip piece
		if (corner_direction % 2 == 1): #flip different ways based on corner orientation
			ipiece.flip_piece(true)
			ipiece.rotate_piece(true)
			
		elif(corner_direction % 2 == 0):
			ipiece.rotate_piece(true)
			ipiece.flip_piece(true)
	for i in (4-(tile_orientation%10))%4: #reorient piece
		ipiece.rotate_piece(true)
		
	return pp



func _on_end_game_button_pressed():
	playersout[1] = true
	if Global.turn == 1:
		next_turn.emit()
	


func _on_reset_button_pressed():
	get_tree().reload_current_scene()
