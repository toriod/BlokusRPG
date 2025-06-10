extends Node

#for tracking the mouse's slot pos
var slot_pos
var slot_id
var mouse_on_board
#for tracking the last piece moved
var selected_slot_pos
var selected_slot_id
var selected_piece
var selected_tile
#for tracking the board state
## 0 is unfilled
## 1 is Player 1 (bottom right)
## 2 is CPU 2 (bottom left)
## 3 is CPU 3 (top left)
## 4 is CPU 4 (top right)
## array is (x,y) = x + width*y
var board_width
var board_height
var board_state_array
var player1corners
var player2corners
var player3corners
var player4corners
var turn
var round

#signal bus
signal confirm_placement

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
