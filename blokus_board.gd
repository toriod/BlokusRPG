extends Sprite2D

@export var outside_height: int = 22
@export var outside_width: int = 22
@export var width: int = 20
@export var height: int = 20
@export var cell_size: int = 48
@export var slot_scene: PackedScene
@onready var grid = $Grid
#signal mouse_in_slot2(slot_pos)
var show_debug: bool = false
var grid_positions = []
#var grid: Dictionary = {}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#@export var board_node: Node2D
func generateGrid():
	Global.board_height = height
	Global.board_width = width
	for y in height:
		for x in width:
#			grid[Vector2(x,y)] = null
			var slot = slot_scene.instantiate()
			slot.position = gridToWorld(Vector2(x,y))+Vector2(outside_width,outside_height)-position
			slot.slot_id = x+y*width
			grid_positions.append(slot.position)
			add_child(slot)
			slot.mouse_in_slot.connect(_on_mouse_in_slot)
				#slot.scale = Vector2(cell_size, cell_size)
				#var rect = ReferenceRect.new()
				#rect.position = gridToWorld(Vector2(x,y))+Vector2(outside_width,outside_height)
				#rect.size = Vector2(cell_size, cell_size)
				#rect.editor_only = false
				#add_child(rect)
			if show_debug:
				var label = Label.new()
				label.position = gridToWorld(Vector2(x,y))+Vector2(outside_width,outside_height)-position
				label.text = str(x+y*width)
				label.modulate = Color(0.545098, 0, 0, 1)
				add_child(label)
# Called when the node enters the scene tree for the first time.
func _ready():
	#print(board_node.global_position)
	generateGrid()
	Global.board_state_array = []
	Global.board_state_array.resize(width*height)
	Global.board_state_array.fill(0)

func gridToWorld(_pos: Vector2) -> Vector2:
	return (_pos * cell_size)
	
func worldToGrid(_pos: Vector2) -> Vector2:
	return (_pos/cell_size).floor()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_mouse_in_slot(slot_pos,slot_id):
	#mouse_in_slot2.emit(slot_pos+position)
	#print("blokus board slot pos ", slot_pos+position)
	Global.slot_pos = slot_pos+position
	Global.slot_id = slot_id
	#print(slot_pos)
	
func update_selected_slot_pos(slot_id):
	Global.selected_slot_pos = grid_positions[slot_id] + position
	print(grid_positions[slot_id])
	
